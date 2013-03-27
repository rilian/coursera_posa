# Using ruby 1.9.3
#
# To run the program, initialize the shell and run command
#
# ruby w4_program.txt
#
# You should see output like
#
#  Ready... Set... Go!
#  Ping!
#  Pong!
#  Ping!
#  Pong!
#  Pong!
#  Ping!
#  Done!
#

require 'thread'

#
# Using Queue class as a critical resource
#
# More info on Queue here http://ruby-doc.org/stdlib-1.9.3/libdoc/thread/rdoc/Queue.html
#
ping_queue = Queue.new
pong_queue = Queue.new

puts 'Ready... Set... Go!'

#
# Pinger thread produces pings and puts them into Ping queue.
# Once pinged, thread waits until the ping will be ponged back
#
pinger = Thread.new do
  3.times do
    # put something into ping queue
    ping_queue << true

    puts 'Ping!'

    # wait until there is something in pong queue, to finish the loop cycle
    pong_queue.pop
  end
end

#
# Ponger thread waits for something appear in the ping queue, and pongs back
#
ponger = Thread.new do
  3.times do
    # wait until ping appear in the ping queue
    ping_queue.pop

    puts 'Pong!'

    # put something into pong queue
    pong_queue << true
  end
end

# Main thread waiting until ponger thread finish
ponger.join

puts 'Done!'


