class MessagesController < ApplicationController
  before_action :set_chat

  def create
    @message = @chat.messages.build(message_params)
    @message.role = 'user'

    if @message.save
      # Generate AI response using LangChain
      generate_ai_response
      redirect_to @chat
    else
      @messages = @chat.messages.order(:created_at)
      render 'chats/show'
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
      # Initialize OpenAI client through LangChain
      llm = Langchain::LLM::OpenAI.new(
        api_key: ENV['OPENAI_API_KEY']
      )

      # Prepare messages in the format expected by chat method
      messages = [
        { role: "system", content: "You are a helpful assistant." }
      ]

      # Add conversation history
      @chat.messages.order(:created_at).each do |msg|
        messages << { role: msg.role, content: msg.content }
      end

      # Generate response using chat method
      response = llm.chat(messages: messages)
      chat_completion = response.chat_completion

      # Save AI response
      @chat.messages.create!(
        content: chat_completion,
        role: 'assistant'
      )
    rescue => e
      # binding.pry # 取消注释此行可以在错误时暂停调试
      # Fallback response if AI fails
      @chat.messages.create!(
        content: "I'm sorry, I'm having trouble connecting to the AI service right now. Please try again later. Error: #{e.message}",
        role: 'assistant'
      )
    end
  end
end
