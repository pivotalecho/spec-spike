require 'capybara/poltergeist'
require 'capybara/rspec'
require 'webrick'
require 'httparty'

Capybara.javascript_driver = :poltergeist
Capybara.app_host = 'http://localhost:3030'

UI_ROOT = File.expand_path('../../dist', __FILE__)
UI_PORT = ENV['ECHO_UI_PORT'] || 3030
API_ROOT = File.expand_path('../../../echo', __FILE__)
API_PORT = ENV['ECHO_API_PORT'] || 3031

Dir[File.expand_path('../support/*.rb', __FILE__)].each { |f| require f }

RSpec.configure do |c|
  c.before(:suite) do
    @acceptance_test_runner = EchoAcceptanceTestRunner.new(
      EchoUIServer.new(UI_ROOT, UI_PORT),
      EchoApiServer.new(API_ROOT, API_PORT)
    )

    @acceptance_test_runner.start
  end

  c.after(:suite) do
    @acceptance_test_runner.stop
  end

  c.alias_example_group_to :feature, type: :feature, js: true
end
