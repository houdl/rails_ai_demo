require 'ruby_llm'
require 'playwright'
require 'base64'
require_relative '../tools/computer_tool'

class ComputerUseService
  COMPUTER_USE_TOOL_SCHEMA = {
    "name" => "computer",
    "description" => "Use a computer to interact with web pages through screenshots and actions",
    "input_schema" => {
      "type" => "object",
      "properties" => {
        "action" => {
          "type" => "string",
          "enum" => ["screenshot", "click", "type", "key", "scroll", "cursor_position"],
          "description" => "The action to perform"
        },
        "coordinate" => {
          "type" => "array",
          "items" => {"type" => "number"},
          "description" => "The [x, y] coordinate for click actions"
        },
        "text" => {
          "type" => "string",
          "description" => "Text to type"
        },
        "scroll_direction" => {
          "type" => "string",
          "enum" => ["up", "down", "left", "right"],
          "description" => "Direction to scroll"
        },
        "scroll_amount" => {
          "type" => "number",
          "description" => "Amount to scroll (pixels)"
        }
      },
      "required" => ["action"]
    }
  }.freeze

  def take_screenshot_of_url(url)
    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      browser = playwright.chromium.launch(headless: true)
      page = browser.new_page
      page.goto(url)
      sleep(2) # Wait for page load
      screenshot_data = page.screenshot(type: 'png')
      browser.close
      Base64.encode64(screenshot_data)
    end
  end

  def interact_with_page(url, &block)
    result = nil
    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      browser = playwright.chromium.launch(
        headless: false,
        args: ['--no-sandbox', '--disable-dev-shm-usage']
      )
      context = browser.new_context(
        viewport: { width: 800, height: 600 },
        userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
      )
      page = context.new_page
      
      page.goto(url) if url
      sleep(2) # Wait for page load
      
      # Create page controller object
      page_controller = PageController.new(page)
      result = block.call(page_controller) if block_given?
      
      browser.close
    end
    result
  end

  def access_page_data(url, instructions)
    begin
      # Use Claude with computer use tools to navigate and extract data
      messages = []
      conversation_history = []
      max_iterations = 15
      iteration = 0
      final_result = nil

      interact_with_page(url) do |page_controller|
        # Take initial screenshot
        initial_screenshot = page_controller.take_screenshot
        
        # Check if screenshot is too large (rough base64 length check)
        if initial_screenshot.length > 200000  # Approximately 150KB base64
          raise "Screenshot too large for model input. Try reducing viewport size or image quality."
        end

        messages = [
          {
            role: 'user',
            content: [
              {
                type: 'image',
                source: {
                  type: 'base64',
                  media_type: 'image/jpeg',
                  data: initial_screenshot
                }
              },
              {
                type: 'text',
                text: instructions
              }
            ]
          }
        ]

        # Configure RubyLLM Chat with computer use tool
        # Use default model from configuration
        chat = RubyLLM.chat
          .with_tool(ComputerTool.new(page_controller))
          .with_temperature(0.1)
        puts "Using default model from configuration"

        # Convert initial multimodal message to RubyLLM format
        text_content = messages.first[:content].find { |c| c[:type] == 'text' }&.dig(:text)
        image_content = messages.first[:content].find { |c| c[:type] == 'image' }

        # Use RubyLLM's built-in image and tool handling
        if image_content && text_content
          # Create a temporary file for the image
          require 'tempfile'
          temp_file = Tempfile.new(['screenshot', '.jpg'])
          temp_file.binmode
          temp_file.write(Base64.decode64(image_content[:source][:data]))
          temp_file.close

          response = chat.ask(text_content, with: temp_file.path)
          temp_file.unlink
        else
          response = chat.ask(text_content || instructions)
        end

        final_result = {
          success: true,
          result: response.content,
          iterations: 1,
          conversation: []
        }
      end

      final_result
    rescue => e
      {
        success: false,
        error: e.message,
        backtrace: e.backtrace.first(5)
      }
    end
  end

  class PageController
    def initialize(page)
      @page = page
    end

    def take_screenshot
      screenshot_data = @page.screenshot(type: 'jpeg', quality: 80)
      Base64.encode64(screenshot_data)
    end

    def click_at(x, y)
      @page.mouse.click(x, y)
      sleep(1)
    end

    def type_text(text)
      @page.keyboard.type(text)
      sleep(0.5)
    end

    def scroll_page(direction: 'down', amount: 300)
      amount = amount.to_f  # Ensure amount is a float
      case direction
      when 'down'
        @page.mouse.wheel(0, amount)
      when 'up'
        @page.mouse.wheel(0, -amount)
      when 'left'
        @page.mouse.wheel(-amount, 0)
      when 'right'
        @page.mouse.wheel(amount, 0)
      end
      sleep(1)
    end

    def press_key(key)
      @page.keyboard.press(key)
      sleep(0.5)
    end

    def execute_action(action_params)
      case action_params['action']
      when 'screenshot'
        {
          type: 'image',
          source: {
            type: 'base64',
            media_type: 'image/jpeg',
            data: take_screenshot
          }
        }
      when 'click'
        if action_params['coordinate']
          x, y = action_params['coordinate']
          click_at(x, y)
          "Clicked at coordinates (#{x}, #{y})"
        else
          "Error: coordinate required for click action"
        end
      when 'type'
        if action_params['text']
          type_text(action_params['text'])
          "Typed: #{action_params['text']}"
        else
          "Error: text required for type action"
        end
      when 'key'
        if action_params['key']
          press_key(action_params['key'])
          "Pressed key: #{action_params['key']}"
        else
          "Error: key required for key action"
        end
      when 'scroll'
        direction = action_params['scroll_direction'] || 'down'
        amount = action_params['scroll_amount'] || 300
        scroll_page(direction: direction, amount: amount)
        "Scrolled #{direction} by #{amount} pixels"
      when 'cursor_position'
        # Return current cursor position if available
        "Cursor position tracking not implemented"
      else
        "Error: Unknown action #{action_params['action']}"
      end
    end
  end
end