# frozen_string_literal: true
worker_processes Integer(ENV['ZZMF_PROCESSES'] || 2)

preload_app false
check_client_connection false

logger Logger.new($stdout)

before_fork do |_server, _worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
end

after_fork do |_server, _worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end
end
