import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "submit"]

  connect() {
    this.element.addEventListener("turbo:submit-start", this.handleSubmitStart.bind(this))
    this.element.addEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
    // 自动聚焦到文本框
    this.textareaTarget.focus()
  }

  handleKeydown(event) {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.submitTarget.click()
    }
  }

  handleSubmitStart() {
    this.submitTarget.disabled = true
    this.submitTarget.textContent = "发送中..."
  }

  handleSubmitEnd() {
    this.submitTarget.disabled = false
    this.submitTarget.textContent = "发送"
    this.textareaTarget.value = ""
    this.textareaTarget.focus()
  }
}
