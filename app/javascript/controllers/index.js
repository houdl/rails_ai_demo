// Import and register all your controllers from the importmap under controllers/*

import FormValidationController from "controllers/form_validation_controller"
import MessageFormController from "controllers/message_form_controller"
import ChatScrollController from "controllers/chat_scroll_controller"

// Register controllers with the global Stimulus application
window.Stimulus.register("form-validation", FormValidationController)
window.Stimulus.register("message-form", MessageFormController)
window.Stimulus.register("chat-scroll", ChatScrollController)
