require 'langchain'

class QdrantService
  COLLECTION_NAME = 'chat_messages'

  def initialize
    # @llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"])
    credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_ACCESS_KEY'])
    @llm = Langchain::LLM::AwsBedrock.new(aws_client_options: {region: 'us-east-1', credentials: credentials}, default_options: {chat_completion_model_name: "anthropic.claude-3-5-sonnet-20240620-v1:0"})
    @qdrant = Langchain::Vectorsearch::Qdrant.new(url: ENV["QDRANT_URL"], api_key: ENV["QDRANT_API_KEY"], index_name: COLLECTION_NAME, llm: @llm)
    ensure_collection_exists
  end

  # Create the default schema for the collection
  def ensure_collection_exists
    begin
      @qdrant.create_default_schema
    rescue => e
      Rails.logger.info("Collection may already exist: #{e.message}")
    end
  end

  # Save a message to Qdrant
  def save_message(message)
    # Prepare payload with message data
    payload = {
      message_id: message.id,
      chat_id: message.chat_id,
      role: message.role,
      created_at: message.created_at.to_i
    }

    # Generate a UUID for the point ID
    point_id = SecureRandom.uuid

    # Save to Qdrant using Langchain
    @qdrant.add_texts(
      texts: [message.content],
      ids: [point_id],
      payload: payload
    )
  end

  # Save multiple messages to Qdrant in batch
  def save_messages(messages)
    texts = []
    ids = []
    payload = {}

    messages.each do |message|
      texts << message.content
      ids << message.id.to_s
      payload[message.id.to_s] = {
        message_id: message.id,
        chat_id: message.chat_id,
        role: message.role,
        created_at: message.created_at.to_i
      }
    end

    @qdrant.add_texts(
      texts: texts,
      ids: ids,
      payload: payload
    )
  end

  # Search for similar messages
  def search_similar(query, limit: 10)
    # Use the vectorsearch tool to find similar messages
    results = @qdrant.similarity_search(
      query: query,
      k: limit
    )

    # Format results to match the expected structure for the controller
    results.select{|result| result['score'].to_f > 0.2 }.map do |result|
      payload = result["payload"]
      {
        "payload" => {
          "message_id" => payload["message_id"],
          "chat_id" => payload["chat_id"],
          "content" => payload["content"],
          "role" => payload["role"],
          "created_at" => payload["created_at"]
        },
        "score" => result["score"]
      }
    end
  end
end
