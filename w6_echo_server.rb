# Ruby 1.9.3
# Using TCPServer class to implement Reactor pattern
# Using plain Ruby to implement Wrapper Facade pattern

require 'socket'

PORT = 2808
DOMAIN = 'localhost'

##
# EchoServerHandler to receive data from EchoClientHandler
#
# Functionality
#
# 1) accept connection from EchoClientHandler
# 2) receive message from EchoClientHandler
# 3) output chunk of data (if not limited by \n or \r)
# 4) output each line, limited by \n or \r
#
class EchoServerHandler < TCPServer
  #
end

puts "Starting up server..."
server = EchoServerHandler.new(DOMAIN, PORT)
puts "Server #{server} started on #{DOMAIN}:#{PORT}"

while (session = server.accept)

  # Establish a new thread for a EchoClientHandler connection
  Thread.start do

    # Inform about the new client handler thread
    thread_id = Thread.current.object_id
    puts "Initializing thread #{thread_id} for this EchoClientHandler"
    puts "Received connection from #{session.peeraddr.inspect}"

    # Waiting for client to say something
    while input = session.gets
      puts "Received: #{input.inspect}"

      # Send back exactly what was input
      puts "Echoing back"
      session.puts "Echo: #{input}"
    end

    # Nothing to do, quit
    puts "Thread #{thread_id} exiting"
  end
end
