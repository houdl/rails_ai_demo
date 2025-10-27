class ComputerUseController < ApplicationController
  def access_page
    url = params[:url]
    instructions = params[:instructions]
    
    if url.blank? || instructions.blank?
      render json: { error: 'URL and instructions are required' }, status: 400
      return
    end

    service = ComputerUseService.new
    result = service.access_page_data(url, instructions)
    
    render json: result
  end

  def screenshot
    url = params[:url]
    
    if url.blank?
      render json: { error: 'URL is required' }, status: 400
      return
    end

    service = ComputerUseService.new
    begin
      screenshot_data = service.take_screenshot_of_url(url)
      
      render json: { 
        success: true, 
        screenshot: screenshot_data,
        url: url
      }
    rescue => e
      render json: { 
        success: false, 
        error: e.message 
      }, status: 500
    end
  end

  def interact
    action_params = params.require(:action).permit!
    
    service = ComputerUseService.new
    begin
      result = service.execute_computer_action(action_params.to_h)
      
      render json: {
        success: true,
        result: result
      }
    rescue => e
      render json: {
        success: false,
        error: e.message
      }, status: 500
    ensure
      service.stop_browser
    end
  end

  def extract_google_play_reviews
    url = params[:url]
    review_count = params[:review_count]&.to_i || 10
    
    if url.blank?
      render json: { error: 'URL is required' }, status: 400
      return
    end

    service = WebPageDataService.new
    result = service.extract_google_play_reviews(url, review_count: review_count)
    
    render json: result
  end

  def extract_page_data
    url = params[:url]
    instructions = params[:instructions]
    
    if url.blank? || instructions.blank?
      render json: { error: 'URL and instructions are required' }, status: 400
      return
    end

    service = WebPageDataService.new
    result = service.extract_page_data(url, instructions)
    
    render json: result
  end
end