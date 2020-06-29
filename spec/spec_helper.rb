
require 'capybara/rspec'
require 'date'
require 'faker'
require 'pg'
require 'pry-byebug'
require 'rspec'
require 'selenium-webdriver'
require 'watir'
require 'yaml'

require 'features/pages_helper.rb'
require 'capybara_config'

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
  config.filter_run_when_matching :focus


  # Print console errors after (type: :feature)
  # FAIL on SEVERE and raise JavaScriptConsoleError
  # https://intellipaat.com/community/16534/is-there-a-way-to-print-javascript-console-errors-to-the-terminal-with-rspec-capybara-selenium
  # OTHER OPTION to show warnings (opted for previous) - https://medium.com/@coorasse/catch-javascript-errors-in-your-system-tests-89c2fe6773b1
  config.after(:each, type: :feature, js: true) do
    console_logs = page.driver.browser.manage.logs.get(:browser)
    unless console_logs.empty?
      errors = console_logs.select { |error| error.level == "SEVERE" && !error.message.empty? }
      errors&.each { |error| raise JavaScriptConsoleError, error.message }
    end
  end

  # persist the browser between examples if the test has the persist: true tag
  config.after(:each, type: :feature, js: true, persist: true) do
    Capybara.current_session.instance_variable_set(:@touched, false)
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  if ENV['DRIVER'] == 'headless'
    Capybara.default_driver = :headless_chrome
    Capybara.javascript_driver = :headless_chrome
  else
    Capybara.default_driver = :chrome
    Capybara.javascript_driver = :chrome
  end

  Capybara.configure do |config|
    config.default_max_wait_time = 10 # seconds
  end
end