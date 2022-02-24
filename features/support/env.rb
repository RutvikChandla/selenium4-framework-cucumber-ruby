require 'selenium/webdriver'
require 'capybara/cucumber'
require 'browserstack/local'
require 'browserstack-automate'
BrowserStack.for "cucumber"

url = "http://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub.browserstack.com/wd/hub"

Capybara.register_driver :browserstack do |app|
	options = Selenium::WebDriver::Options.chrome
	options.browser_version = ENV['SELENIUM_VERSION'] || 'latest'
	options.platform_name = 'MAC'

	bstack_options = {
		"os" => "OS X",
		"osVersion" => "Sierra",
		"buildName" =>  ENV['BS_AUTOMATE_BUILD'] || "Final-Snippet-Test",
		"sessionName" => "Cucumber test",
		"local" => "false",
		"seleniumVersion" => "4.0.0",
	}
	if bstack_options['local'] && bstack_options['local'] == 'true';
		@bs_local = BrowserStack::Local.new
		bs_local_args = { "key" => "#{ENV['BS_AUTHKEY']}", "forcelocal" => true }
		@bs_local.start(bs_local_args)
	end
	options.add_option('bstack:options', bstack_options)
  	Capybara::Selenium::Driver.new(app, :browser => :remote, :url => url, :capabilities => options)
end

Capybara.default_driver = :browserstack
Capybara.app_host = "http://www.google.com"
Capybara.run_server = false

at_exit do
  @bs_local.stop unless @bs_local.nil? 
end
