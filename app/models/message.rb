class Message < ApplicationRecord
  belongs_to :chat

  validates :content, presence: true
  validates :role, presence: true, inclusion: { in: %w[user assistant] }

  scope :user_messages, -> { where(role: 'user') }
  scope :assistant_messages, -> { where(role: 'assistant') }

  after_create :save_to_qdrant

  private

  def save_to_qdrant
    QdrantService.new.save_message(self)
  rescue => e
    Rails.logger.error("Failed to save message to Qdrant: #{e.message}")
  end
end
