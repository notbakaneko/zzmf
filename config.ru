# frozen_string_literal: true

# Configure Unicorn
if defined?(Unicorn)
  require 'unicorn/worker_killer'
  # set to whatever you find reasonable
  # 4000 requests to 5000*1.5 requests
  use Unicorn::WorkerKiller::MaxRequests, 5000, 7500, false

  # set to whatever you find reasonable
  oom_min = 450 * (1024**2)
  oom_max = 500 * (1024**2)
  # Max memory size (RSS) per worker
  use Unicorn::WorkerKiller::Oom, oom_min, oom_max
end

# Load App
require_relative 'config/application'
require_relative 'lib/zzmf/thumbnailer/file_origin'
require_relative 'lib/zzmf/request_validators/basic'

# require_relative 'lib/zzmf/thumbnailer/file_output'
# m = Zzmf::Thumbnailer::FileOrigin::Action.send(:prepend, Zzmf::Thumbnailer::FileOutput)
require_relative 'lib/zzmf/thumbnailer/buffer_output'
m = Zzmf::Thumbnailer::FileOrigin::Action.send(:prepend, Zzmf::Thumbnailer::BufferOutput)

m.send(:include, Zzmf::RequestValidators::Basic)

run Zzmf::Thumbnailer::FileOrigin::Run.new
