class SearchesController < ApplicationController
  def index
    # Just render the search form
  end

  def search
    query = params[:query].to_s.strip

    if query.present?
      # Use AI to generate search results
      @results = ai_search(query)
      @total_count = @results.length
    else
      @results = []
      @total_count = 0
    end

    render :index
  end

  private

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
