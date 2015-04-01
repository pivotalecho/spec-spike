require 'webrick'

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
