class MessagesController < ApplicationController
  before_action :set_chat

  def create
    @message = @chat.messages.build(message_params)
    @message.role = 'user'

    respond_to do |format|
      if @message.save
        # Generate AI response using LangChain
        generate_ai_response

        format.turbo_stream do
          # After AI response is generated, show both user message and AI response
          ai_response = @chat.messages.last

          render turbo_stream: [
            turbo_stream.append("messages-container", partial: "messages/message", locals: { message: @message }),
            turbo_stream.append("messages-container", partial: "messages/message", locals: { message: ai_response }),
            turbo_stream.replace("message-form", partial: "messages/form", locals: { chat: @chat, message: Message.new }),
            turbo_stream.replace("chat-sidebar", partial: "chats/sidebar", locals: { current_chat: @chat })
          ]
        end
        format.html { redirect_to @chat }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("message-form", partial: "messages/form", locals: { chat: @chat, message: @message })
        end
        format.html do
          @messages = @chat.messages.order(:created_at)
          render 'chats/show'
        end
      end
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def generate_ai_response
    begin
      # Ge user messages
      messages = []
      @chat.messages.order(:created_at).each do |msg|
        messages << Langchain::Assistant::Messages::OpenAIMessage.new(role: msg.role, content: msg.content )
      end

      # Initialize LLM and Assistant with Calculator tool
      # llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"])
      credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_ACCESS_KEY'])
      llm = Langchain::LLM::AwsBedrock.new(aws_client_options: {region: 'us-east-1', credentials: credentials}, default_options: {chat_completion_model_name: "anthropic.claude-3-5-sonnet-20240620-v1:0"})
      tools = [Langchain::Tool::Calculator.new, TestTool.new]

      assistant = Langchain::Assistant.new(
        llm: llm,
        instructions: "You're a helpful AI assistant",
        tools: tools,
        messages: messages
      )

      latest_message = @chat.messages.where(role: 'user').last
      if latest_message
        # Add user message and run the assistant
        response = assistant.add_message_and_run!(content: latest_message.content)
        message = assistant.messages.last

        # Save AI response
        @chat.messages.create!(
          content: message.content,
          role: 'assistant'
        )
      end
    rescue => e
      # Fallback response if AI fails
      @chat.messages.create!(
        content: "I'm sorry, I'm having trouble connecting to the AI service right now. Please try again later. Error: #{e.message}",
        role: 'assistant'
      )
    end
  end
end
