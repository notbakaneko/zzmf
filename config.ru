# frozen_string_literal: true

# Load App
require_relative 'config/application'

# Pick pipeline options
if Application.config.origin_type == :remote
  require_relative 'lib/zzmf/thumbnailer/remote_origin'
  require_relative 'lib/zzmf/loaders/buffer'

  OriginModule = Zzmf::Thumbnailer::RemoteOrigin
  ThumbnailerLoader = Zzmf::Loaders::Buffer
else
  require_relative 'lib/zzmf/thumbnailer/file_origin'
  require_relative 'lib/zzmf/loaders/file'

  OriginModule = Zzmf::Thumbnailer::FileOrigin
  ThumbnailerLoader = Zzmf::Loaders::File
end

require_relative 'lib/zzmf/thumbnailer/buffer_output'
OutputModule = Zzmf::Thumbnailer::BufferOutput
# require_relative 'lib/zzmf/thumbnailer/file_output'
# OutputModule = Zzmf::Thumbnailer::FileOutput


# link origin with output
m = OriginModule::Action.send(:prepend, OutputModule)

# chain the loader
m.send(:include, ThumbnailerLoader)

# Add validators
require_relative 'lib/zzmf/request_validators/basic'
m.send(:include, Zzmf::RequestValidators::Basic)

run OriginModule::Run.new
