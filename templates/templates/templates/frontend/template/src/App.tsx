import { Link, Route, Routes } from "react-router"

import { ContactPage } from "./pages/ContactPage"
import { HomePage } from "./pages/HomePage"
import { NotFoundPage } from "./pages/NotFoundPage"

export function App() {
  return (
    <div className="min-h-screen bg-white dark:bg-slate-950">
      <nav className="border-b border-slate-200 p-4 dark:border-slate-800">
        <Link to="/" className="mr-4 font-medium">
          Inicio
        </Link>
        <Link to="/contacto" className="font-medium">
          Contacto
        </Link>
      </nav>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/contacto" element={<ContactPage />} />
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </div>
  )
}
