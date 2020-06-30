# frozen_string_literal: true

require_relative '../page_helper'

class LoginPage
  include Capybara::DSL

  # Objects
  LOGO = 'h1.logo'
  LOGO_LINK = "a[href='https://invoiced.com']"
  LOGIN_FORM = 'form[name=loginForm]'
  EMAIL_FIELD = 'input[type=email]'
  PASSWORD_FIELD = 'input[type=password]'
  REMEMBER_ME_CHKBOX = 'input[type=checkbox'
  FORGOT_PASSWORD_LINK = "a[ui-sref='auth.forgot({email:email})']"
  SIGN_IN_BTN = 'button[type=submit]'
  GOOGLE_BTN = 'div.button.google'
  SSO_LOGIN_LINK = 'div.sso-link'
  SIGN_UP_LINK = "a[href='https://invoiced.com/signup']"
  HELP_ICON = 'div.help-icon'
  INVALID_LOGIN_ALERT = 'div.alert.alert-danger'

  # Methods
  def login_page_reached?
    page.has_css?(LOGIN_FORM)
  end

  def invalid_login_alert_message
    find(INVALID_LOGIN_ALERT).text
  end

  def validate_login_form_elements
    begin
      within find(LOGIN_FORM) do
        page.has_css?(EMAIL_FIELD)
        page.has_css?(PASSWORD_FIELD)
        page.has_css?(REMEMBER_ME_CHKBOX)
        page.has_css?(FORGOT_PASSWORD_LINK)
        page.has_css?(SIGN_IN_BTN)
      end
    rescue Capybara::ElementNotFound
      false
    end
  end

  def login_user(username, password)
    find(EMAIL_FIELD).set username
    find(PASSWORD_FIELD).set password
    find(SIGN_IN_BTN).click
  end
end
