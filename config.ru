# frozen_string_literal: true

require_relative 'config/application'
require_relative 'lib/thumbnailer/file_origin'
# require_relative 'lib/thumbnailer/remote_origin'

require_relative 'lib/thumbnailer/file_output'
Thumbnailer::FileOrigin::Action.send(:prepend, Thumbnailer::FileOutput)
# require_relative 'lib/thumbnailer/buffer_output'
# Thumbnailer::FileOrigin::Action.send(:prepend, Thumbnailer::BufferOutput)

run Thumbnailer::FileOrigin::Run.new
