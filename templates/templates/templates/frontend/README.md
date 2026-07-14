# Template: frontend

Genera una SPA con React + TypeScript + Vite lista para produccion con cambios minimos, siguiendo la arquitectura fija definida en `SPEC.md` (raiz del repo).

Pensado para consumir cualquiera de los backends de este repo (`api`, `webservice`, `agentic`, `chatbot`) via su URL base.

## Uso

```bash
../../new.sh frontend ./mi-panel
# o equivalente:
uvx copier copy --trust templates/frontend ./mi-panel
```

## Preguntas

| Variable | Que controla |
|---|---|
| `project_name` / `project_slug` / `project_description` / `author_name` | Metadatos del proyecto (`package.json`, `index.html`, README) |
| `api_base_url` | URL base del backend (`VITE_API_BASE_URL` en `.env`) |
| `node_version` | Version usada en Dockerfile y CI |

No hay toggle de auth: `src/lib/api-client.ts` ya manda el header `X-API-Key` si `VITE_API_KEY` esta definido en `.env`, y simplemente lo omite si no — no hace falta una pregunta de copier para eso.

## Lo que genera

- Vite + React 19 + TypeScript, linter `oxlint` (el que trae el scaffold oficial de Vite)
- React Router para las rutas, TanStack Query para el estado del servidor, React Hook Form + Zod para formularios (ver `src/components/ContactForm.tsx` como ejemplo)
- Tailwind CSS v4 (via el plugin de Vite, sin `tailwind.config.js`)
- `src/lib/api-client.ts`: wrapper de `fetch` con `VITE_API_BASE_URL` y header opcional `X-API-Key`
- `vitest` + Testing Library para tests de componentes (`npm run test`)
- `Dockerfile` multi-stage (build con Node, sirve con nginx) + `docker-compose.yml`
- `.github/workflows/ci.yml`: lint, typecheck, test, build

**Importante:** las variables `VITE_*` se hornean en el bundle al momento de `npm run build` — no son configurables en runtime como en un backend. Si cambias `VITE_API_BASE_URL` para otro ambiente, hay que reconstruir la imagen.

## Validar el template despues de editarlo

```bash
uvx copier copy --trust --data project_name="Demo Frontend" --data project_description="demo" -f templates/frontend /tmp/demo-frontend
cd /tmp/demo-frontend && npm install && npm run lint && npm run typecheck && npm run test && npm run build
```
