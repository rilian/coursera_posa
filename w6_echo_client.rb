require 'socket'

PORT = 2808
DOMAIN = 'localhost'

##
# Client to access EchoServerHandler
#
# Functionality
#
# 1) connect to EchoServerHandler
# 2) send some data
#  - a "chunk" at a time or
#  - a "line" at a time, ending with \n or \r
# 3) output server replies
#
class EchoClientHandler < TCPSocket
  #
end

# Validate if can connect to server
begin
  clientSession = TCPSocket.new(DOMAIN, PORT)
rescue
  puts "Connection to #{DOMAIN}:#{PORT} refused"
  exit
end

puts "Starting client connection"

# Array of strings to send to EchoServerHandler
what_to_say = ['hello1', "hello2\n", "hello3\r"].reverse

# "Say" all given strings, while session is active
while !(clientSession.closed?) && (message = what_to_say.pop)
  puts "Sending #{message.inspect}"
  clientSession.puts message

  puts "Waiting for response"
  serverMessage = clientSession.gets
  puts "Received: #{serverMessage}"

  # Close connection when everything is said
  if what_to_say.empty?
    puts "Enuff said, closing connection"
    clientSession.close
    puts "connection closed"
  end
end
