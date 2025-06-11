class SearchesController < ApplicationController
  def index
    # Just render the search form
  end

  def search
    query = params[:query].to_s.strip

    if query.present?
      # Use Qdrant vector search with Langchain
      @results = vector_search(query)
      @total_count = @results.length
    else
      @results = []
      @total_count = 0
    end

    render :index
  end

  private

  def vector_search(query)
    begin
      # Use QdrantService to search for similar messages
      qdrant_service = QdrantService.new
      search_results = qdrant_service.search_similar(query, limit: 10)

      # Format the results for display
      search_results.map do |result|
        payload = result["payload"]

        # Find the message in the database to get associated chat title
        message = Message.find_by(id: payload["message_id"])
        chat_title = message&.chat&.title || "Unknown Chat"

        {
          "title" => "Chat: #{chat_title}",
          "content" => payload["content"],
          "source" => payload["role"],
          "date" => Time.at(payload["created_at"]).strftime("%Y-%m-%d %H:%M"),
          "relevance_score" => result["score"],
          "message_id" => payload["message_id"],
          "chat_id" => payload["chat_id"]
        }
      end
    rescue => e
      # If vector search fails, fall back to AI search
      Rails.logger.error "Vector search failed: #{e.message}"
      ai_search(query)
    end
  end

  def ai_search(query)
    begin
      # First get basic database results
      basic_results = Message.includes(:chat).order(created_at: :desc).limit(100)

      # Format the messages for AI analysis
      messages_data = basic_results.map do |msg|
        {
          id: msg.id,
          chat_id: msg.chat_id,
          chat_title: msg.chat.title,
          role: msg.role,
          content: msg.content,
          created_at: msg.created_at.strftime("%Y-%m-%d %H:%M")
        }
      end

      # Prepare messages for the AI
      messages = [
        Langchain::Assistant::Messages::OpenAIMessage.new(
          role: 'system',
          content: "You are a search assistant. Your task is to search through message content based on a query and format relevant results as JSON."
        ),
        Langchain::Assistant::Messages::OpenAIMessage.new(
          role: 'user',
          content: "I'm searching for: '#{query}' in the following messages:\n\n#{messages_data.to_json}\n\nPlease analyze these messages and return only the ones relevant to my search query."
        )
      ]

      # Initialize LLM and Assistant
      llm = Langchain::LLM::OpenAI.new(api_key: ENV["OPENAI_API_KEY"])
      # credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_ACCESS_KEY'])
      # llm = Langchain::LLM::AwsBedrock.new(aws_client_options: {region: 'us-east-1', credentials: credentials}, default_options: {chat_completion_model_name: "anthropic.claude-3-5-sonnet-20240620-v1:0"})

      # qdrant = Langchain::Vectorsearch::Qdrant.new(url: ENV["QDRANT_URL"], api_key: ENV["QDRANT_API_KEY"], index_name: QdrantService::COLLECTION_NAME, llm: llm)
      # vectorsearch_tool = Langchain::Tool::Vectorsearch.new(vectorsearch: qdrant)
      assistant = Langchain::Assistant.new(
        llm: llm,
        instructions: "You're a search assistant that searches through message content and formats relevant results as JSON.",
        messages: messages
      )

      # Get AI response
      response = assistant.add_message_and_run!(content: "Search for '#{query}' in the provided messages and format the relevant results as JSON with the following structure:
      [
        {
          \"title\": \"Chat: [chat_title]\",
          \"content\": \"[message content]\",
          \"source\": \"[user or assistant]\",
          \"date\": \"[created_at]\",
          \"relevance_score\": [0.0-1.0],
          \"message_id\": [id],
          \"chat_id\": [chat_id]
        }
      ]
      Only include messages that are relevant to the search query '#{query}'. Sort by relevance_score in descending order.")

      message = assistant.messages.last

      # Parse JSON from AI response
      json_string = message.content.gsub(/```json|```/, '').strip

      # Extract JSON from the response if it's embedded in text
      json_match = json_string.match(/\[.*?\]/m)
      json_string = json_match[0] if json_match

      JSON.parse(json_string)
    rescue => e
      # If AI search fails, return empty array
      Rails.logger.error "AI search failed: #{e.message}"
      []
    end
  end
end
