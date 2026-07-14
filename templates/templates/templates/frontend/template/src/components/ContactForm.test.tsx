import { render, screen } from "@testing-library/react"
import userEvent from "@testing-library/user-event"
import { describe, expect, it, vi } from "vitest"

import { ContactForm } from "./ContactForm"

describe("ContactForm", () => {
  it("shows validation errors on empty submit", async () => {
    const onSubmit = vi.fn()
    render(<ContactForm onSubmit={onSubmit} />)

    await userEvent.click(screen.getByRole("button", { name: /enviar/i }))

    expect(await screen.findByText("Requerido")).toBeInTheDocument()
    expect(await screen.findByText("Email invalido")).toBeInTheDocument()
    expect(onSubmit).not.toHaveBeenCalled()
  })

  it("calls onSubmit with valid data", async () => {
    const onSubmit = vi.fn()
    render(<ContactForm onSubmit={onSubmit} />)

    await userEvent.type(screen.getByLabelText(/nombre/i), "Danilo")
    await userEvent.type(screen.getByLabelText(/email/i), "danilo@example.com")
    await userEvent.click(screen.getByRole("button", { name: /enviar/i }))

    expect(onSubmit).toHaveBeenCalledWith(
      { name: "Danilo", email: "danilo@example.com" },
      expect.anything(),
    )
  })
})
