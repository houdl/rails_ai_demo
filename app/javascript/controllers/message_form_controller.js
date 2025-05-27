import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "submit"]

  handleKeydown(event) {
    // 按 Ctrl+Enter 或 Cmd+Enter 发送消息
    if ((event.ctrlKey || event.metaKey) && event.key === "Enter") {
      event.preventDefault()
      this.submitTarget.click()
    }
  }

  connect() {
    // 自动聚焦到文本框
    this.textareaTarget.focus()
  }
}
