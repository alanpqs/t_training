# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'email_spec'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  
  def test_log_in(user)
    controller.log_in(user)
  end
  
  def test_vendor_cookie(user)
    controller.vendor_cookie(user)
  end
  
  def test_selected_vendor_cookie(vendor)
    controller.selected_vendor_cookie(vendor)
  end
  
  def test_resource_cookie(resource)
    controller.resource_cookie(resource)
  end
  
  def integration_log_in(user)
    visit login_path
    fill_in :email,    :with => user.email
    fill_in :password, :with => user.password
    click_button
  end

end
