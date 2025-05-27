class ChatsController < ApplicationController
  before_action :set_chat, only: [:show, :destroy]

  def index
    @chats = Chat.order(updated_at: :desc)
  end

  def show
    @messages = @chat.messages.order(:created_at)
    @message = Message.new
  end

  def new
    @chat = Chat.new
  end

  def create
    @chat = Chat.new(chat_params)

    if @chat.save
      redirect_to @chat, notice: 'Chat was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @chat.destroy
    redirect_to chats_url, notice: 'Chat was successfully deleted.'
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:title)
  end
end
