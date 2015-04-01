require 'capybara/poltergeist'
require 'capybara/rspec'
require 'webrick'
require 'httparty'

Capybara.javascript_driver = :poltergeist
Capybara.app_host = 'http://localhost:3030'

UI_ROOT = File.expand_path('../dist', __FILE__)
UI_PORT = ENV['ECHO_UI_PORT'] || 3030
API_ROOT = File.expand_path('../../echo', __FILE__)
API_PORT = ENV['ECHO_API_PORT'] || 3031

# Dir[File.expand_path('support/*.rb', File.dirname(__FILE__))].each { |f| require f }
class EchoAcceptanceTestRunner
  def initialize(*servers)
    @servers = servers
  end

  def start
    @servers.each do |server|
      print "\nWaiting for #{server.name} to start..."
      server.start
      wait(server.url)
    end
    puts "\nStarting specs"
  end

  def stop
    @servers.each do |server|
      server.stop
    end
  end

  private

  def wait(url)
    pp url
    10.times do
      begin
        response = HTTParty.get(url)
        break if response.success?
      rescue
        p $!
        10.times do
          print '.'
          sleep 0.1
        end
      end
    end
  end
end

class EchoApiServer
  def initialize(root, port)
    @root = root
    @port = port
    @rack_config = File.expand_path('config.ru', @root)
  end

  def start
    @api_server_pid = Process.spawn(
      "rackup #{@rack_config} -p #{@port}", 
      chdir: @root, 
      pgroup: true
      # [:out, :err] => '/dev/null'
    )
  end

  def stop
    Process.kill('-TERM', @api_server_pid)
    Process.wait(@api_server_pid)
  end

  def name
    'Api Server'
  end

  def url
    "http://localhost:#{@port}"
  end
end

class EchoUIServer
  def initialize(root, port)
    @root = root
    @port = port
  end

  def start
    @ui_pid = fork do
      STDOUT.reopen('/dev/null')
      STDOUT.reopen('/dev/null')
      @server = WEBrick::HTTPServer.new(
        Port: @port, 
        DocumentRoot: @root, 
        Logger: WEBrick::Log.new("/dev/null"),
        AccessLog: []
      )

      Signal.trap('TERM') {
        @server.shutdown
      }

      @server.start
    end
  end

  def stop
    Process.kill('TERM', @ui_pid)
    Process.wait(@ui_pid)
  end

  def name
    'UI Server'
  end

  def url
    "http://localhost:#{@port}"
  end
end

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
