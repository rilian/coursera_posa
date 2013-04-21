# Dining philosophers with Monitor solution

require 'monitor'

class Fork
  include MonitorMixin

  attr_reader :number

  def initialize(number)
    super()

    @number = number

    #state is "ON_TABLE" or "ON_HAND"
    @state = "ON_TABLE"
    @on_table_cond = new_cond
  end

  def pickup
    self.synchronize do
      @on_table_cond.wait_while { @state == "ON_HAND"}
      @state = "ON_HAND"
    end
  end

  def putdown
    synchronize do
      @state = "ON_TABLE"
      @on_table_cond.signal
    end
  end
end

class Philosophy
  attr_reader :number

  def initialize(number, forks)
    @number = number
    @forks = forks
  end

  def direction(fork)
    if fork.number == number
      "right"
    else
      "left"
    end
  end

  def eat
    puts "Philosopher #{number + 1} eats"
  end

  def lower_fork
    if @forks[0].number <  @forks[1].number
      @forks[0]
    else
      @forks[1]
    end
  end

  def higher_fork
    if @forks[0].number > @forks[1].number
      @forks[0]
    else
      @forks[1]
    end
  end
end

# initalize Forks and Philosophers
forks = []
5.times do |i|
  forks << Fork.new(i)
end

philosophies = []
5.times do |i|
  left_fork = forks[(5 + i - 1)%5]
  right_fork = forks[i]
  philosophies << Philosophy.new(i, [left_fork, right_fork])
end

# setup 5 threads
# each thread drives a Philosopher's action
puts 'Dinner is starting!'
threads = []
5.times do |i|

  threads[i] = Thread.new do
    5.times do |_|
      p = philosophies[i]

      # the philosopher first pickup the lower numbered fork,
      # then pick up the higher numbered fork
      fork_1 = p.lower_fork
      fork_1.pickup
      puts "Philosopher#{i + 1} picks up #{p.direction(fork_1)} fork"

      fork_2 = p.higher_fork
      fork_2.pickup
      puts "Philosopher #{i + 1} picks up #{p.direction(fork_2)} fork"

      p.eat

      fork_2.putdown
      fork_1.putdown
    end
  end
end

threads.each {|t| t.join }
