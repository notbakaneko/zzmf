# frozen_string_literal: true

workers Integer(ENV['ZZMF_PROCESSES'] || 4)
threads 4, 4

quiet

require 'puma_worker_killer'

PumaWorkerKiller.config do |config|
  config.ram           = 3072
  config.frequency     = 30
  config.percent_usage = 0.95
  config.rolling_restart_frequency = 12 * 3600
  config.reaper_status_logs = false

  config.pre_term = ->(worker) { puts "Worker #{worker.inspect} being killed" }
end

before_fork do
  PumaWorkerKiller.start
end
