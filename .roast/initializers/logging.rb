# .roast/initializers/logging.rb
ActiveSupport::Notifications.subscribe(/roast\./) do |name, start, finish, id, payload|
  duration = finish - start
  puts "[#{name}] completed in #{duration.round(3)}s"
end