require 'socket'
require 'timeout'

# Acceptor-Connector
class Connector

  attr_reader :connection_method

  def initialize(connection_method)
    @connection_method = connection_method
    self.connect
  end

  def connect
    case @connection_method
    when 'Sockets'
      @connector = TCPSocket.new 'localhost', 2000
    else
      raise NotImplementedError, 'Not implemented connection method.'
    end
  end

  def establish_connection(msg)
    if @connector.closed?
      self.connect
    end

    @connector.puts msg

    data = nil
    begin
      timeout(5) do
        data = @connector.recvfrom 1024
      end
    rescue Timeout::Error
      puts "Timed out!"
    end

    data.each do |line|
      puts line.chomp if !line.nil?
    end

    self.close
  end

  def close
    @connector.close
  end
end

connector = Connector.new 'Sockets'

100.times do |i|
  connector.establish_connection "Test number #{i}. This is coming back from the server."
end

