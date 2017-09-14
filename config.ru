# frozen_string_literal: true

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
