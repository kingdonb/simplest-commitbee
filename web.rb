# http_server.rb
require 'socket'
server = TCPServer.new 5000

while session = server.accept
  begin
  request = session.gets
  # puts request

  session.print "HTTP/1.1 200\r\n" # 1
  session.print "Content-Type: text/html\r\n" # 2
  session.print "\r\n" # 3
  session.print '{"ok":true}' #4

  session.close
  rescue StandardError => e
    # the health checker closes the connection after receiving:
    # HTTP/1.1 200\r\n
    # do not let this crash the web server, just silently eat it
  end
end
