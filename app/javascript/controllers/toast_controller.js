import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 4000 } }

  connect() {
    // Slide in
    requestAnimationFrame(() => this.element.classList.add("toast-visible"))

    // Auto-dismiss
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.classList.remove("toast-visible")
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
    // Fallback removal if transition doesn't fire
    setTimeout(() => this.element.remove(), 300)
  }
}
