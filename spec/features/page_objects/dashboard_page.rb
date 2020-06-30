# frozen_string_literal: true

require_relative '../page_helper'

class DashboardPage
  include Capybara::DSL

  # Objects
  SCREEN_LOADED = 'div.pg-loading-screen.pg-loading.pg-loaded'
  # Methods

  def screen_loaded
    SCREEN_LOADED
  end
end