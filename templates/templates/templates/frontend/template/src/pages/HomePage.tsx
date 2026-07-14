import { useQuery } from "@tanstack/react-query"

import { apiFetch } from "../lib/api-client"

interface HealthResponse {
  status: string
}

export function HomePage() {
  const { data, isLoading, isError } = useQuery({
    queryKey: ["health"],
    queryFn: () => apiFetch<HealthResponse>("/health"),
  })

  return (
    <main className="mx-auto max-w-2xl p-8">
      <h1 className="text-2xl font-semibold text-slate-900 dark:text-slate-100">
        Inicio
      </h1>
      <p className="mt-2 text-slate-600 dark:text-slate-400">
        Estado del backend:{" "}
        {isLoading && <span>cargando...</span>}
        {isError && <span className="text-red-600">sin conexion</span>}
        {data && <span className="text-green-600">{data.status}</span>}
      </p>
    </main>
  )
}
