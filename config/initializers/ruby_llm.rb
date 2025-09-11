require 'ruby_llm'
require 'ruby_llm/mcp'
require 'ruby_llm/schema'

RubyLLM.configure do |config|
  # open ai 的 schema 是生效的，aws 的不生效
  config.openai_api_key = ENV['OPENAI_API_KEY']

  # config.bedrock_api_key = ENV['AWS_ACCESS_KEY']
  # config.bedrock_secret_key = ENV['AWS_SECRET_ACCESS_KEY']
  # config.bedrock_region = ENV['AWS_REGION']

  # config.default_model = 'us.anthropic.claude-3-7-sonnet-20250219-v1:0'
end