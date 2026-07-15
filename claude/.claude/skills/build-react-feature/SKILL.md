---
name: build-react-feature
description: "Builds or reviews a React feature end to end. Invoked when: adding a new UI feature or component, wiring a component to an API, or reviewing a React PR for production-readiness. Covers: functional components, TypeScript typing, reusable hooks, loading/error states, and accessibility."
---

<skill>
Build or review the React feature and apply the following checklist. Fix every issue found and explain each change in one line.

## Style
- No AI-looking code: no filler comments, no single-call helper components — inline logic until a second real use case justifies extracting it.
- Types only where they aid comprehension, not padding every prop with redundant annotation.

## Components
- Functional components only — no class components, no `this`.
- Component stays small: if the JSX scrolls past one screen, split it into subcomponents.
- Props are explicitly typed with an interface or type, not `any` or implicit `object`.

## Hooks
- Any stateful logic used in more than one place is extracted into a custom hook, not copy-pasted.
- `useEffect` dependency arrays are complete — no suppressed lint warnings papering over stale closures.
- Data fetching goes through a typed hook/client, not inline `fetch` scattered through components.

## Loading and error state
- Every async operation (fetch, mutation) has an explicit loading state shown to the user, not a blank screen.
- Every async operation has an explicit error state with a user-facing message — errors aren't swallowed in a `catch` that only logs to console.
- Empty-data state is handled distinctly from loading and error (don't show a spinner forever when the result is just empty).

## Accessibility
- Interactive elements are real `<button>`/`<a>`, not `<div onClick>`.
- Form inputs have associated `<label>` elements (or `aria-label`).
- Color contrast and focus states are visible; keyboard-only navigation works for every interactive element.

## Output format
For each issue found:
```
[ISSUE] <file>:<line or section> — <description>
[FIX]   <what was changed and why>
```
Then show the corrected component code.
</skill>
