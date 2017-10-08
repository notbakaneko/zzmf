# frozen_string_literal: true

# Load App
require_relative 'config/application'

# Pick pipeline options

require_relative 'lib/zzmf/thumbnailer/file_origin'
OriginModule = Zzmf::Thumbnailer::FileOrigin
# require_relative 'lib/zzmf/thumbnailer/remote_origin'
# OriginModule = Zzmf::Thumbnailer::RemoteOrigin

require_relative 'lib/zzmf/loaders/file'
ThumbnailerLoader = Zzmf::Loaders::File
# require_relative 'lib/zzmf/loaders/buffer'
# ThumbnailerLoader = Zzmf::Loaders::Buffer

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
