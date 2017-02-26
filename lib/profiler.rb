# frozen_string_literal: true

class Profiler #:nodoc:
  def self.profile(name)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield if block_given?
  ensure
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    $stdout.puts "Completed #{name} in #{(elapsed * 100).round(6)} ms"
  end

  def initialize
    @start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def lap(name)
    elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start
    $stdout.puts "Completed #{name} in #{(elapsed * 100).round(6)} ms"
  end
end
