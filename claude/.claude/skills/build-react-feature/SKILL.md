---
name: build-react-feature
description: "React/TypeScript UI work. Invoked when: adding or changing a component or UI feature, wiring a component to an API, or reviewing a React PR."
---

<skill>
Build or review the React feature and apply the following checklist. Fix every issue found and explain each change in one line.

Stack: **React**, **TypeScript**, **Tailwind** for styling. Style rules live in AGENTS.md and already apply — here that mostly means inlining logic until a second real use case justifies extracting a hook or component, and typing props where it aids comprehension rather than padding every prop.

## Components
- Functional components only — no class components, no `this`.
- Component stays small: if the JSX scrolls past one screen, split it into subcomponents.
- Props are explicitly typed with an interface or type, not `any` or implicit `object`.
- Co-locate a component's styles, types, and tests with the component, not in far-away parallel trees.

## Hooks and state
- Any stateful logic used in more than one place is extracted into a custom hook, not copy-pasted.
- `useEffect` dependency arrays are complete — no suppressed lint warnings papering over stale closures.
- Data fetching goes through a typed hook/client, not inline `fetch` scattered through components.
- Server state (API data) and client state (UI toggles, form drafts) stay in separate mechanisms — don't shove both into one global store.
- Prop drilling more than two levels means a hook or context is missing, not that Redux is needed. Reach for local state and a hook before any global store.

## Loading and error state
- Every async operation (fetch, mutation) has an explicit loading state shown to the user, not a blank screen.
- Every async operation has an explicit error state with a user-facing message — errors aren't swallowed in a `catch` that only logs to console.
- Empty-data state is handled distinctly from loading and error (don't show a spinner forever when the result is just empty).

## Accessibility
- Interactive elements are real `<button>`/`<a>`, not `<div onClick>`.
- Form inputs have associated `<label>` elements (or `aria-label`).
- Color contrast and focus states are visible; keyboard-only navigation works for every interactive element.

## Checks
- The feature isn't done until `npm run lint && npm run format:check && npm run build` passes — run it yourself; most projects wire it up as `npm run check`.
- `build` type-checks (`tsc -b`), so a green build covers types; `format:check` is `prettier --check .` and is fixed with `npm run format`, never by hand.
- Run `npm run test` (vitest) as well when the change touches behavior that has tests.

## Output format
For each issue found:
```
[ISSUE] <file>:<line or section> — <description>
[FIX]   <what was changed and why>
```
Then show the corrected component code. Call out any interactive element missing an accessible name or keyboard handler.
</skill>
