import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Auto-scroll to bottom when new messages are added
    this.scrollToBottom()
  }

  messageAdded() {
    // Called when a new message is added via Turbo Stream
    this.scrollToBottom()

    // Remove empty state if it exists
    const emptyState = document.getElementById("empty-state")
    if (emptyState) {
      emptyState.remove()
    }
  }

  scrollToBottom() {
    const container = document.getElementById("messages-container")
    if (container) {
      container.scrollTop = container.scrollHeight
    }
  }
}
