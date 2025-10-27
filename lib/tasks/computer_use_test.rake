namespace :computer_use do
  desc "Test Google Play reviews extraction"
  task test_google_play: :environment do
    url = "https://play.google.com/store/apps/details?id=com.binance.dev"
    
    puts "Testing Google Play reviews extraction..."
    puts "URL: #{url}"
    puts "=" * 50
    
    service = WebPageDataService.new
    result = service.extract_google_play_reviews(url, review_count: 5)
    
    if result[:success]
      puts "✅ Success!"
      puts "\nExtracted Reviews:"
      puts "-" * 30
      
      if result[:reviews].any?
        result[:reviews].each_with_index do |review, index|
          puts "Review ##{index + 1}:"
          puts "Rating: #{review[:rating] || 'N/A'} stars" if review[:rating]
          puts "Content: #{review[:content]}" if review[:content]
          puts "Raw: #{review[:raw_text][0..100]}..." if review[:raw_text]
          puts "-" * 20
        end
      end
      
      puts "\nSummary:"
      puts result[:summary]
      
      puts "\nMetadata:"
      puts "App URL: #{result[:metadata][:app_url]}"
      puts "Extraction Time: #{result[:metadata][:extraction_time]}"
    else
      puts "❌ Failed:"
      puts "Error: #{result[:error]}"
      puts "Iterations: #{result[:iterations]}" if result[:iterations]
    end
  end
  
  desc "Test custom page data extraction"
  task test_custom_page: :environment do
    url = ENV['TEST_URL'] || "https://example.com"
    instructions = ENV['TEST_INSTRUCTIONS'] || "Take a screenshot and describe what you see on this page"
    
    puts "Testing custom page data extraction..."
    puts "URL: #{url}"
    puts "Instructions: #{instructions}"
    puts "=" * 50
    
    service = WebPageDataService.new
    result = service.extract_page_data(url, instructions)
    
    if result[:success]
      puts "✅ Success!"
      puts "\nExtracted Data:"
      puts result[:data]
    else
      puts "❌ Failed:"
      puts "Error: #{result[:error]}"
    end
  end
  
  desc "Test Claude computer use"
  task test_claude: :environment do
    url = "https://play.google.com/store/apps/details?id=com.binance.dev"
    instructions = "查看这个页面的一条评论信息."
    
    service = ComputerUseService.new
    result = service.access_page_data(url, instructions)
    
    if result[:success]
      puts "✅ Success!"
      puts "-" * 30
      puts result[:result]
      
      puts "\nProcess Details:"
      puts "Iterations used: #{result[:iterations]}"
      puts "Conversation length: #{result[:conversation].length} exchanges"
    else
      puts "❌ Failed:"
      puts "Error: #{result[:error]}"
      puts "Iterations attempted: #{result[:iterations]}" if result[:iterations]
      
      if result[:conversation]
        puts "\nConversation log:"
        result[:conversation].each_with_index do |msg, i|
          puts "#{i + 1}. #{msg[:role]}: #{msg[:content].to_s[0..100]}..."
        end
      end
    end
  end
end