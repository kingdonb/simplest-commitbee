# tcp-server.rb
# from https://github.com/digital-fabric/libev_scheduler/blob/main/examples/tcp-server.rb
# with some modifications

require 'bundler/setup'
require 'fiber_scheduler'

require 'socket'

scheduler = FiberScheduler.new
Fiber.set_scheduler scheduler

server = TCPServer.new('0.0.0.0', 5000)

Fiber.schedule do
  loop do
    p pre: server
    client = server.accept
    p client: client

    Fiber.schedule do
      begin
        client.recv(1024)
        client.send("HTTP/1.1 200 Ok\r\nContent-Type: application/json\r\nConnection: close\r\n\r\n",0)
        client.send('{"ok":true}',0)
        client.close
      rescue StandardError => e
        # the health checker closes the connection after receiving:
        # HTTP/1.1 200\r\n
        # do not let this crash the web server, just silently eat it
      end
    end
  end
end
