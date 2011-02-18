require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  
  #RAILS_ENV=test rake sunspot:solr:start
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  #require 'factory_girl_rails'
  #Factory.find_definitions

  require 'email_spec'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  Dir[Rails.root.join("spec/factories/*.rb")].each {|f| require f}

  #Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f} -- old version

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    #config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true
  
     ### Part of a Spork hack. See http://bit.ly/arY19y
	   # Emulate initializer set_clear_dependencies_hook in
	   # railties/lib/rails/application/bootstrap.rb
	   
	   ActiveSupport::Dependencies.clear
	   
	   
  end 
end

Spork.each_run do
  # This code will be run each time you run your specs.
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

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.

  
	   
	   
	   
	  

