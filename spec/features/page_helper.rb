# frozen_string_literal: true

Dir[File.dirname(__FILE__) + '/page_objects/**/*.rb'].each {|file| require file }

module PagesHelper
  include Capybara::DSL

  # ***************************** General Pages  *****************************
  # use this section to define the normal name for page objects/ page classes
  # replaces the let statement in rspec
  #
  def login_page
    LoginPage.new
  end

  def sso_page
    SsoPage.new
  end

  def dashboard_page
    DashboardPage.new
  end

  # ***************************** PageHelper methods  *****************************
  # generic methods across the app, not defined to a single page

  DEFAULT_WAIT_TIME = 10

  # site log in helpers
  #
  def persist_browser
    Capybara.current_session.instance_variable_set(:@touched, true)
  end

  def wait_for_block(delay_time = DEFAULT_WAIT_TIME)
    Timeout.timeout(delay_time) do
      sleep(0.1) until (value = yield)
      value
    end
  end

  def reload_page
    page.evaluate_script('window.location.reload()')
  end

  def rescue_exceptions
    yield
  rescue Capybara::ElementNotFound, Selenium::WebDriver::Error::StaleElementReferenceError, Selenium::WebDriver::Error::InvalidSelectorError
    false
  end

  # handy helper to return true or false if element isn't visible instead of getting an exception
  def displayed?(locator = {})
    rescue_exceptions { find(locator).present? }
  end

  def scroll_to(element)
    # you may need to call this with the visible: false attributes
    script = <<-JS
      console.log('Scrolling to:', arguments[0]);
      setTimeout(() => {
        // https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollIntoViewIfNeeded
        arguments[0].scrollIntoViewIfNeeded(true);
      }, 500);
    JS
    Capybara.current_session.driver.browser.execute_script(script, element.native)
    page.driver.browser.manage.logs.get(:browser)
  rescue Selenium::WebDriver::Error::UnknownError
    element.native.location_once_scrolled_into_view
  end

  def refresh_browser
    visit(current_url)
  end

  def console_check
    console_logs = page.driver.browser.manage.logs.get(:browser)
    unless console_logs.empty?
      errors = console_logs.select { |error| error.level == "SEVERE" && !error.message.empty? }
      errors&.each { |error| raise JavaScriptConsoleError, error.message }
    end
  end


  # TODO - TESTRAIL STUFF
  #   def update_feature_test_run(file, suite_id, test_case_ids)
  #     return unless should_report_test_plan?
  #     Timecop.return do
  #       run_name = 'Feature Test - ' + file + ' - ' + Time.now.strftime('%D at %r').to_s
  #       update_feature_test_plan(run_name, suite_id, test_case_ids)
  #     end
  #   end

  # Find a table on the page and convert it to an array of arrays.
  # selector_or_node - A String CSS selector to find the table, or a
  #                    Nokogiri::XML::Node object (if you already have a
  #                    reference to the table).
  # options          - Optional hash:
  #                    columns - An Integer or Range of Integers. Lets you
  #                              select a slice of columns. Useful if one of
  #                              the columns is used solely for interaction
  #                              purposes (e.g., contains buttons or
  #                              checkboxes).
  #                    as      - A Symbol. How to convert cell content. :html
  #                              will get the content as HTML, :text will strip
  #                              the HTML. (Default: :text)
  # Returns an Array of Arrays. Each outer Array is a row, each inner Array is a
  # cell.
  VALID_FORMATS = [:html, :text]
  def table_contents(selector_or_node, options = {})
    format = options[:as] || :text
    selected_columns = options[:columns]
    selected_rows = options[:rows]
    if selected_columns && !selected_columns.is_a?(Range)
      selected_columns = Range.new(selected_columns, selected_columns)
    end
    if selected_rows && !selected_rows.is_a?(Range)
      selected_rows = Range.new(selected_rows, selected_rows)
    end
    # Wait for the element to appear on the page
    find(selector_or_node)
    if selector_or_node.is_a?(Nokogiri::XML::Node)
      trs = selector_or_node.css('tr')
    else
      doc = Nokogiri::HTML.parse(page.html)
      trs = doc.css("#{selector_or_node} tr")
    end
    rows = []
    trs.each_with_index do |tr, i|
      next unless selected_rows.nil? || selected_rows.include?(i)
      cells = []
      tr.css('th, td').each_with_index do |td, j|
        next unless selected_columns.nil? || selected_columns.include?(j)
        cells << case format
                 when :html then
                   td.inner_html
                 when :text then
                   td.content.strip.squish
                 end
      end
      rows << cells
    end
    rows
  end

  def flash(element)
    background_color = style('backgroundColor')
    element_color = execute_script('arguments[0].style.backgroundColor', element)
    10.times do |n|
      color = n.even? ? 'red' : background_color
      execute_script("arguments[0].style.backgroundColor = '#{color}'", element)
    end
    execute_script('arguments[0].style.backgroundColor = arguments[1]', element, element_color)
  end

end

# ******************** CUSTOM ERROR CLASSES ********************************
#
# To capture JavaScript Console Errors
class JavaScriptConsoleError < StandardError; end