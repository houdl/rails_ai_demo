import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }

  // 当有新消息时调用此方法
  messageAdded() {
    setTimeout(() => {
      this.scrollToBottom()
    }, 100)
  }
}
