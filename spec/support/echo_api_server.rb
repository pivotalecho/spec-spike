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
      pgroup: true,
      [:out, :err] => '/dev/null'
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
