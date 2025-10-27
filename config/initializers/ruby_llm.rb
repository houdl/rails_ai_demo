require 'ruby_llm'
require 'ruby_llm/mcp'
require 'ruby_llm/schema'

RubyLLM.configure do |config|
  config.request_timeout = 300        # 5 minutes
  config.max_retries = 5              # More retry attempts
  config.retry_interval = 1.0         # Start with 1 second delay
  config.retry_backoff_factor = 1.5   # Less aggressive backoff

  config.default_model = 'us.anthropic.claude-3-7-sonnet-20250219-v1:0'

  # AWS Bedrock configuration for Claude models
  config.bedrock_api_key = ENV['AWS_ACCESS_KEY_ID']
  config.bedrock_secret_key = ENV['AWS_SECRET_ACCESS_KEY']
  config.bedrock_region = ENV['AWS_REGION'] || 'us-east-1'
end