
describe 'Login to Invoiced demo app', type: :feature, js: true do
  include PagesHelper

  before :all do
    creds = YAML.load_file('spec/test_data/login_data.yml')
    @username = creds['username']
    @password = creds['password']
  end

  before :each do
    visit '/login'
  end

  it 'can open the login page' do
    expect(login_page.login_page_reached?).to be_truthy
  end

  it 'validates the login form on the login page' do
    expect(login_page.validate_login_form_elements).to be_truthy
  end

  context "Valid login data" do
    it 'allows user to login with valid username and password' do
      login_page.login_user(@username, @password)
      while page.has_css?('.pg-loading')
        sleep 0.1
      end
      expect(current_url).to eq('https://dashboard.invoiced.com/dashboard')
    end
  end

  context 'Invalid Login data' do
    it 'shows invalid message and console error with bad email' do
      login_page.login_user('bad_email@example.com', @password)
      expect(login_page.invalid_login_alert_message).to eq("We could not find a match for that email address and password.")
      expect{ console_check }.to raise_error(JavaScriptConsoleError)
    end

    it 'shows invalid message and console error with bad password' do
      login_page.login_user(@username, 'badPassword')
      expect(login_page.invalid_login_alert_message).to eq("We could not find a match for that email address and password.")
      expect{ console_check }.to raise_error(JavaScriptConsoleError)
    end

    it 'temporarily locks the user out after too many invalid attempts' do
      3.times do
        login_page.login_user(@username, 'badPassword')
        refresh_browser
      end
      lockout_message = "This account has been locked due to too many failed sign in attempts."
      expect(login_page.invalid_login_alert_message).to include(lockout_message)
    end
  end
end
