require 'socket'
require 'thread'
require 'monitor'
require 'timeout'

# Acceptor-Connector
class Acceptor
  def initialize(connection_method)
    case connection_method
    when 'Sockets'
      @server = TCPServer.new 2000 # Server bound to port 2000
    else
      raise NotImplementedError, 'Not implemented connection method.'
    end
  end

  def await_connection
    @server.accept
  end
end

# Half-Sync/Half-Async
class ServerQueue
  attr_reader :thread_counter, :max_threads_number

  def initialize(max_threads_number)
    @thread_counter = 0
    @max_threads_number = max_threads_number
    @queue = Queue.new

    # Creates a Queue with 8 "Tickets", a Thread can only run when it has a Ticket
    # Maximum number of Threads running for this test is 8
    @max_threads_number.times do
      @queue << :ticket
    end
  end

  def get_ticket
    @queue.pop
    @thread_counter += 1
  end

  def return_ticket
    @queue << :ticket
    @thread_counter -= 1
  end
end

# Service Handler (used by Reactor)
class EchoServerHandler
  @@lock = Monitor.new

  # Sends a "line" at a time
  def echo(client)
    data = nil
    begin
      timeout(5) do
        data = client.recvfrom 1024
      end
    rescue Timeout::Error
      puts "Timed out!"
    end

    @@lock.synchronize do
      data.each do |line|
        client.puts line
      end
    end
  end
end

# Reactor
class Reactor
  def initialize(connection_method, max_threads_number)
    @acceptor = Acceptor.new connection_method
    @services = {:echo => EchoServerHandler.new}
    @queue = ServerQueue.new max_threads_number
  end

  def run_server_event_loop
    loop do
      # Main Thread locks until new tickets are avaliable in the Queue
      @queue.get_ticket

      Thread.start(@acceptor.await_connection) do |client| # Wait for a client to connect and launch new thread on connection
        puts 'Thread #' + @queue.thread_counter.to_s
        @services[:echo].echo client
        puts "MSG SENT!"
        sleep 0.5 # This was only added to make testing easier and assert the number of running threads, IT CAN BE REMOVED
        client.close
        @queue.return_ticket
      end

    end
  end
end

# Wrapper Facade
class Server
  def initialize(connection_method, max_threads_number)
    @reactor = Reactor.new connection_method, max_threads_number
  end

  def start
    puts "Server now accepting connections! Now please run the client file in ANOTHER window."
    @reactor.run_server_event_loop
  end
end

# Starts Server
# The Server will uses Sockets and a maximum of 8 threads in Half-Sync layer
server = Server.new 'Sockets', 8
server.start

