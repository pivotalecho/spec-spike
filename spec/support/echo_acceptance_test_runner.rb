require 'httparty'

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
