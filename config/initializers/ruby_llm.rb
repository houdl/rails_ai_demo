require 'ruby_llm'
require 'ruby_llm/mcp'

RubyLLM.configure do |config|
  config.bedrock_api_key = ENV['AWS_ACCESS_KEY']
  config.bedrock_secret_key = ENV['AWS_SECRET_ACCESS_KEY']
  config.bedrock_region = ENV['AWS_REGION']

  config.default_model = 'us.anthropic.claude-3-7-sonnet-20250219-v1:0'
end