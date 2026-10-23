---
name: react-best-practices
description: >
  Expert-level React guidance for production-grade applications. Trigger this skill whenever the user asks about React architecture, component design, state management, performance, hooks, WebRTC integration, admin UI patterns, real-time data, or frontend code review. Also trigger when the user shares React/JSX code and asks for feedback, improvements, or debugging help. Covers React 18+, TypeScript, Zustand, React Query, WebRTC softphone UIs, and contact center frontend patterns.
---

# React Best Practices

## Guiding Philosophy

- **Complexity is a liability.** Every abstraction must earn its place. If you can delete it, delete it.
- **Server state and client state are different problems.** Mixing them is the root cause of most React bugs.
- **Be opinionated.** When reviewing code, flag problems clearly. "This is wrong because X" beats "you might consider Y."
- This stack targets a **contact center admin UI** with real-time data, WebRTC softphone, and full CRUD over VoIP entities (extensions, queues, DIDs, IVR flows). Keep that context in mind.

---

## State Management

### The Hierarchy (follow it strictly)

1. **Local `useState`** — component-scoped UI state (open/close, input values). Default choice.
2. **React Query / TanStack Query** — all server state. No exceptions.
3. **Zustand** — global client state that is truly shared (active call state, softphone status, WebSocket event bus, auth session). Not a Redux replacement for everything.
4. **`useReducer`** — complex local state machines (IVR flow builder node state, multi-step forms).
5. **Context** — dependency injection only (theme, auth context, socket context). Never for frequently-changing state.

### Anti-patterns to reject immediately

```tsx
// ❌ Storing server data in useState + useEffect fetching
const [users, setUsers] = useState([]);
useEffect(() => { fetch('/api/users').then(r => r.json()).then(setUsers); }, []);

// ✅ React Query owns server state
const { data: users, isLoading } = useQuery({ queryKey: ['users'], queryFn: fetchUsers });
```

```tsx
// ❌ Bloated Context causing full-tree re-renders
const AppContext = createContext({ user, calls, agents, queues, ... });

// ✅ Split contexts by update frequency; hot state goes to Zustand
```

### Zustand store patterns

```ts
// ✅ Slice pattern — one store, multiple slices
interface CallSlice {
  activeCalls: Call[];
  addCall: (call: Call) => void;
  removeCall: (id: string) => void;
}

const useStore = create<CallSlice & AuthSlice>()(
  devtools(
    immer((...a) => ({
      ...createCallSlice(...a),
      ...createAuthSlice(...a),
    }))
  )
);
```

---

## Component Architecture

### Rules

- **One responsibility per component.** If you're writing "and" in a component description, split it.
- **Colocate everything.** `UserCard.tsx`, `UserCard.test.tsx`, `UserCard.module.css` in one folder.
- **Smart/dumb split is dead.** Use hooks to extract logic; keep components as thin rendering shells.
- **Prefer composition over prop drilling past 2 levels.** Use children, render props, or Zustand.

### Naming conventions

| Pattern | Convention |
|---|---|
| Components | `PascalCase` |
| Hooks | `useNoun` or `useVerbNoun` |
| Event handlers | `handleEventName` (not `onClick` as a prop name) |
| Query keys | `['resource', id, filters]` tuple arrays |

### Component file structure

```tsx
// 1. Imports (external → internal → types)
// 2. Types/interfaces
// 3. Constants
// 4. Component function
// 5. Sub-components (only if tightly coupled and not reused)
// 6. Default export
```

---

## Hooks

### Custom hook rules

- Extract any logic that crosses 2+ components or involves side effects into a custom hook.
- Hooks must be pure with respect to React's rules — no conditionals wrapping hook calls, ever.
- Name reflects what it returns, not how it works: `useExtension(id)` not `usePjsipEntityFetcher`.

### Common patterns for this stack

```ts
// ✅ Typed query hook wrapping React Query
export function useExtension(id: string) {
  return useQuery({
    queryKey: ['extensions', id],
    queryFn: () => api.extensions.get(id),
    staleTime: 30_000,
  });
}

// ✅ Mutation with cache invalidation
export function useUpdateExtension() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: api.extensions.update,
    onSuccess: (_, { id }) => {
      qc.invalidateQueries({ queryKey: ['extensions', id] });
      qc.invalidateQueries({ queryKey: ['extensions'] });
    },
  });
}
```

### WebSocket / real-time hook

```ts
export function useAsteriskEvents(event: string, handler: (data: unknown) => void) {
  const socket = useSocketContext(); // from Context — stable reference
  useEffect(() => {
    socket.on(event, handler);
    return () => socket.off(event, handler);
  }, [socket, event, handler]); // handler must be stable (useCallback at call site)
}
```

---

## Performance

### When to optimize (not before)

Profile first with React DevTools Profiler. Premature memoization adds cognitive overhead for zero gain.

### Memoization rules

- `useMemo` — expensive computations only (filtering large lists, derived data from raw API responses).
- `useCallback` — callbacks passed to memoized children, or deps in `useEffect`.
- `React.memo` — components that render frequently with stable props (table rows, call cards).

```tsx
// ❌ Pointless memo — rerenders anyway because `onClick` is a new reference each render
const Button = memo(({ label, onClick }) => <button onClick={onClick}>{label}</button>);

// ✅ Stabilize the callback at the parent
const handleDelete = useCallback(() => deleteUser(id), [id]);
```

### Large list rendering

Use `@tanstack/react-virtual` for agent lists, call queues, CDR tables. Never render 500+ rows unvirtualized.

---

## WebRTC Softphone Integration

### Architecture

```
SIP.js / JsSIP  ←→  Kamailio WSS  ←→  Asterisk
     ↕
Zustand (call state: idle | ringing | active | held)
     ↕
SoftphoneWidget (UI only, reads store)
```

### Non-negotiables

- **Audio context must be created on user gesture.** Never autoplay without interaction.
- **Session cleanup on component unmount.** `session.terminate()` in useEffect cleanup.
- **ICE candidate handling must be async.** Don't assume synchronous SDP exchange.
- **DTLS/SRTP only.** No plain RTP over WSS transport.

```ts
// ✅ Clean session lifecycle
useEffect(() => {
  const session = ua.invite(target, sessionOptions);
  return () => {
    if (session.state !== SessionState.Terminated) {
      session.terminate();
    }
  };
}, [target]);
```

### WSS connection

```ts
const ua = new UserAgent({
  uri: UserAgent.makeURI(`sip:${ext}@${domain}`),
  transportOptions: {
    server: `wss://${domain}/ws`, // Nginx → Kamailio
    traceSip: process.env.NODE_ENV === 'development',
  },
  sessionDescriptionHandlerFactoryOptions: {
    constraints: { audio: true, video: false },
    iceGatheringTimeout: 2000,
  },
});
```

---

## TypeScript

- **No `any`.** Use `unknown` and narrow. If you're fighting the type system, your data model is wrong.
- **Generate API types from OpenAPI spec** (use `openapi-typescript`). Don't hand-write what FastAPI already knows.
- **Zod for runtime validation** of WebSocket events and external data that TypeScript can't protect at runtime.

```ts
const AsteriskEventSchema = z.discriminatedUnion('type', [
  z.object({ type: z.literal('ChannelCreated'), channel: ChannelSchema }),
  z.object({ type: z.literal('ChannelDestroyed'), channel: ChannelSchema }),
]);

socket.on('event', (raw) => {
  const result = AsteriskEventSchema.safeParse(raw);
  if (!result.success) { console.error('Bad event', raw); return; }
  // result.data is typed
});
```

---

## Code Review Checklist

When reviewing React code, check in this order:

1. **Is server state managed by React Query?** If useState+useEffect, flag it.
2. **Does any Context update at high frequency?** If yes, move to Zustand.
3. **Are side effects cleaned up?** Every `useEffect` with subscriptions/timers needs a return.
4. **Is memoization justified?** Unjustified `memo`/`useMemo` = delete it.
5. **Are key props stable and unique?** No array index keys on dynamic lists.
6. **Is TypeScript strict?** No `any`, no `@ts-ignore` without explanation.
7. **Are WebRTC session lifetimes managed?** Unterminated sessions are silent resource leaks.
8. **Is error state handled?** `isError` from React Query must be surfaced, not ignored.
