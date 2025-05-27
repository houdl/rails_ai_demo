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

    respond_to do |format|
      if @chat.save
        format.turbo_stream { redirect_to @chat }
        format.html { redirect_to @chat, notice: 'Chat was successfully created.' }
      else
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new }
      end
    end
  end

  def destroy
    @chat.destroy
    respond_to do |format|
      format.turbo_stream { redirect_to chats_url }
      format.html { redirect_to chats_url, notice: 'Chat was successfully deleted.' }
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:title)
  end
end
