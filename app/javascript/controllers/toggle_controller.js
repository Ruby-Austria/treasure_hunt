import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "label"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = this.contentTarget.classList.contains("hidden") ? "Show" : "Hide"
    }
  }
}
