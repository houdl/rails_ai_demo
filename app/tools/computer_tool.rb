require 'ruby_llm'

class ComputerTool < RubyLLM::Tool
  description "Use a computer to interact with web pages through screenshots and actions"
  
  param :action, desc: "The action to perform: screenshot, click, type, key, scroll"
  param :coordinate, desc: "The [x, y] coordinate for click actions", required: false
  param :text, desc: "Text to type", required: false
  param :scroll_direction, desc: "Direction to scroll: up, down, left, right", required: false
  param :scroll_amount, desc: "Amount to scroll (pixels)", required: false

  def initialize(page_controller = nil)
    @page_controller = page_controller
  end

  def execute(action:, coordinate: nil, text: nil, scroll_direction: 'down', scroll_amount: 300, **kwargs)
    scroll_amount = scroll_amount.to_f if scroll_amount  # Ensure scroll_amount is a float
    return "Error: No page controller available" unless @page_controller

    case action
    when 'screenshot'
      {
        type: 'image',
        source: {
          type: 'base64',
          media_type: 'image/jpeg',
          data: @page_controller.take_screenshot
        }
      }
    when 'click'
      if coordinate
        x, y = coordinate
        @page_controller.click_at(x, y)
        "Clicked at coordinates (#{x}, #{y})"
      else
        "Error: coordinate required for click action"
      end
    when 'type'
      if text
        @page_controller.type_text(text)
        "Typed: #{text}"
      else
        "Error: text required for type action"
      end
    when 'key'
      if kwargs[:key]
        @page_controller.press_key(kwargs[:key])
        "Pressed key: #{kwargs[:key]}"
      else
        "Error: key required for key action"
      end
    when 'scroll'
      @page_controller.scroll_page(direction: scroll_direction, amount: scroll_amount)
      "Scrolled #{scroll_direction} by #{scroll_amount} pixels"
    else
      "Error: Unknown action #{action}"
    end
  end
end