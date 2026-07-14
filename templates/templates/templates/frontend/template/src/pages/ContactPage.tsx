import { ContactForm } from "../components/ContactForm"

export function ContactPage() {
  return (
    <main className="mx-auto max-w-2xl p-8">
      <h1 className="text-2xl font-semibold text-slate-900 dark:text-slate-100">
        Contacto
      </h1>
      <div className="mt-4">
        <ContactForm onSubmit={(values) => console.log(values)} />
      </div>
    </main>
  )
}
