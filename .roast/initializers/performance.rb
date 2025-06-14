# .roast/initializers/performance.rb
ActiveSupport::Notifications.subscribe("roast.step.complete") do |name, start, finish, id, payload|
  duration = finish - start
  if duration > 10.0
    puts "WARNING: Step '#{payload[:step_name]}' took #{duration.round(1)}s"
  end
end