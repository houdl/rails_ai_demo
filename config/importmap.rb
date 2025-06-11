# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "bootstrap" # @5.3.6
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

# Pin local JavaScript files
pin_all_from "app/javascript/controllers", under: "controllers"
