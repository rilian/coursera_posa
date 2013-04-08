require 'thread'
require 'mutex_m'

puts 'Dinner is starting!'

# Chopstick has own id and mutex, so it can be taken only once at a time
# see ruby's stdlib mutex_m.rb source for more info
Chopstick = Struct.new(:id, :mutex)
chopsticks = Array.new(5) { |i| Chopstick.new(i, Object.new.extend(Mutex_m)) }

class Philosopher
  # Philosopher has id, and reference to left and right chopstick
  # for simplicity we do not parametrize number of meals to eat and names etc
  def initialize(id, left_chopstick, right_chopstick)
    @id, @left_chopstick, @right_chopstick = id, left_chopstick, right_chopstick
    @meals = 0
  end

  # Run "computations" until philosopher eats 5 times, then Thread will quit
  def run
    while @meals < 5
      eat
    end
  end

  def eat
    left_chopstick, right_chopstick = @left_chopstick, @right_chopstick
    while true
      puts "Philosopher #{@id} picks up left chopstick."
      pick_chopstick(left_chopstick, true)

      if pick_chopstick(right_chopstick)
        # here we quit waiting for chopsticks since all of them are taken by this Philosopher. Hooray!
        puts "Philosopher #{@id} picks up right chopstick."
        break
      end

      # If not break before, then this Philosopher cannot take some chopstick, so he release everything
      release_chopstick(left_chopstick)
      left_chopstick, right_chopstick = right_chopstick, left_chopstick
    end

    puts "Philosopher #{@id} eats."

    sleep(rand) # this is not required but output looks cooler ;)

    @meals += 1

    # Unlock chopstick mutexes
    release_chopstick(@left_chopstick)
    release_chopstick(@right_chopstick)
  end

  # Try to access chopstick
  # in case should_wait=true we expect the mutex to be in locked state here
  def pick_chopstick(chopstick, should_wait=false)
    should_wait ? chopstick.mutex.mu_lock : chopstick.mutex.mu_try_lock
  end

  # Release chopstick
  # just unlock mutex
  def release_chopstick(chopstick)
    chopstick.mutex.unlock
  end
end

# Initialize each Philosopher in own thread
# set it's chopsticks references and run
philosophers = Array.new(5) do |i|
  Thread.new(i, chopsticks[i], chopsticks[(i + 1) % 5]) do |id, c1, c2|
    Philosopher.new(id, c1, c2).run
  end
end

# With join, Main thread would wait for each of Philosopher threads to finish
philosophers.each { |thread| thread.join }

puts 'Dinner is over!'
