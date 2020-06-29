# frozen_string_literal: true

# Headless chrome for feature tests - https://robots.thoughtbot.com/headless-feature-specs-with-chrome
# Options: https://peter.sh/experiments/chromium-command-line-switches/
chrome_options = Selenium::WebDriver::Chrome::Options.new
chrome_options.add_argument('--window-size=1920,1080')
chrome_options.add_argument('--start-maximized')
chrome_options.add_argument('--disable-infobars')
chrome_options.add_argument('--disable-popup-blocking')
chrome_options.add_argument('--no-sandbox')

# base url
Capybara.app_host = 'https://dashboard.invoiced.com'

Capybara.register_driver(:chrome) { |app|
  Capybara::Selenium::Driver.new(app, {
      browser: :chrome,
      clear_local_storage: true,
      clear_session_storage: true,
      options: chrome_options
  })
}

# to run chrome in headless mode change javascript.driver to :headless_chrome, otherwise use :chrome
# Options: https://peter.sh/experiments/chromium-command-line-switches/
Capybara.register_driver(:headless_chrome) { |app|
  chrome_options.add_argument('--headless')
  Capybara::Selenium::Driver.new(app, {
      browser: :chrome,
      clear_local_storage: true,
      clear_session_storage: true,
      options: chrome_options
  })
}

Capybara.configure { |config|
  config.default_driver = :chrome
  config.default_max_wait_time = 10 # default is 2

  config.javascript_driver = if ENV['DRIVER'] == 'headless'
                               :headless_chrome
                             else
                               :chrome
                             end

  config.threadsafe = true
  config.server = :puma
}
