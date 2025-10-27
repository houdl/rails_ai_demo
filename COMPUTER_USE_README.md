# Computer Use Service

This service implements Claude's Computer Use functionality with Ruby LLM and Playwright to access web page data automatically.

## Features

- **Automated Web Navigation**: Uses Playwright to control browsers and navigate websites
- **Computer Use Integration**: Implements Claude's computer use tool schema for AI-driven web interactions
- **Google Play Reviews Extraction**: Specialized functionality to extract app reviews from Google Play Store
- **Custom Page Data Extraction**: General-purpose web scraping with AI guidance
- **Screenshot Capabilities**: Take and process screenshots for AI analysis

## Components

### Services

1. **ComputerUseService** (`app/services/computer_use_service.rb`)
   - Core computer use functionality
   - Implements Claude's computer use tool schema
   - Handles browser automation with Playwright
   - Provides screenshot, click, type, scroll, and key press actions

2. **WebPageDataService** (`app/services/web_page_data_service.rb`)
   - High-level web data extraction
   - Google Play reviews extraction
   - Custom page data extraction with AI guidance

### Controller

**ComputerUseController** (`app/controllers/computer_use_controller.rb`)
- REST API endpoints for computer use functionality
- JSON responses for easy integration

## API Endpoints

### 1. Take Screenshot
```bash
POST /computer_use/screenshot
Content-Type: application/json

{
  "url": "https://example.com"
}
```

### 2. Extract Google Play Reviews
```bash
POST /computer_use/extract_google_play_reviews
Content-Type: application/json

{
  "url": "https://play.google.com/store/apps/details?id=com.binance.dev",
  "review_count": 10
}
```

### 3. Custom Page Data Extraction
```bash
POST /computer_use/extract_page_data
Content-Type: application/json

{
  "url": "https://example.com",
  "instructions": "Find all product prices and descriptions on this page"
}
```

### 4. Direct Computer Interaction
```bash
POST /computer_use/interact
Content-Type: application/json

{
  "action": {
    "action": "click",
    "coordinate": [100, 200]
  }
}
```

### 5. Access Page with Custom Instructions
```bash
POST /computer_use/access_page
Content-Type: application/json

{
  "url": "https://example.com",
  "instructions": "Navigate to the reviews section and extract the first 5 reviews"
}
```

## Computer Use Tool Actions

The service supports these computer actions:

- `screenshot`: Take a screenshot of the current page
- `click`: Click at specific coordinates `[x, y]`
- `type`: Type text into the current focus
- `key`: Press a specific key (e.g., "Enter", "Tab")
- `scroll`: Scroll in a direction with specified amount
- `cursor_position`: Get current cursor position

## Usage Examples

### Using Rails Console

```ruby
# Extract Google Play reviews
service = WebPageDataService.new
result = service.extract_google_play_reviews(
  "https://play.google.com/store/apps/details?id=com.binance.dev",
  review_count: 10
)

puts result[:success] ? result[:summary] : result[:error]

# Custom page extraction
result = service.extract_page_data(
  "https://news.ycombinator.com",
  "Get the titles and scores of the top 5 stories"
)
```

### Using Rake Tasks

```bash
# Test Google Play extraction
rake computer_use:test_google_play

# Test custom page extraction
TEST_URL="https://example.com" TEST_INSTRUCTIONS="Describe the page" rake computer_use:test_custom_page

# Test basic service functionality
rake computer_use:test_service
```

### Using cURL

```bash
# Extract Google Play reviews
curl -X POST http://localhost:3000/computer_use/extract_google_play_reviews \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://play.google.com/store/apps/details?id=com.binance.dev",
    "review_count": 5
  }'

# Take a screenshot
curl -X POST http://localhost:3000/computer_use/screenshot \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

## Configuration

The service uses Claude Haiku 4.5 model via AWS Bedrock. Configuration is in `config/initializers/ruby_llm.rb`:

```ruby
RubyLLM.configure do |config|
  # AWS Bedrock configuration for Claude models
  config.bedrock_api_key = ENV['AWS_ACCESS_KEY_ID']
  config.bedrock_secret_key = ENV['AWS_SECRET_ACCESS_KEY']
  config.bedrock_region = ENV['AWS_REGION'] || 'us-east-1'
  
  # Default to Claude Haiku 4.5 for computer use
  config.default_model = 'claude-haiku-4-5-20251001-v1:0'
end
```

Make sure you have the following environment variables set:
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key
- `AWS_REGION`: AWS region (defaults to us-east-1)

The service specifically uses **Claude Haiku 4.5** (`claude-haiku-4-5-20251001-v1:0`) which is optimized for computer use tasks with:
- Fast response times
- Excellent vision capabilities for screenshot analysis
- Strong reasoning for web navigation tasks

## Dependencies

The service requires these gems (already in Gemfile):
- `ruby_llm` (1.4.0) - LLM client with Claude support
- `playwright-ruby-client` - Browser automation
- `ruby_llm-mcp` - MCP protocol support
- `ruby_llm-schema` - Schema validation

## Installation

1. Make sure Playwright is installed:
```bash
npx playwright install
```

2. Set up environment variables:
```bash
export OPENAI_API_KEY="your-api-key"
```

3. Start the Rails server:
```bash
rails server
```

## Error Handling

The service includes comprehensive error handling:
- Browser startup/shutdown management
- Network timeout handling
- AI model response validation
- Screenshot capture errors
- Invalid coordinate/action errors

## Limitations

- Requires a display/GUI environment for browser rendering
- AI model token limits may restrict conversation length
- Some websites may have anti-automation measures
- Browser resource usage for concurrent requests

## Example: Google Play Reviews Extraction Flow

1. Navigate to Google Play Store app page
2. Take initial screenshot for AI analysis
3. AI identifies "See all reviews" section
4. Click on reviews section
5. Scroll through reviews collecting data
6. Parse and structure review information
7. Provide summary analysis of reviews

The service handles the entire flow automatically based on AI guidance.