# frozen_string_literal: true

require_relative 'config/application'
require_relative 'lib/thumbnailer/file_origin'
# require_relative 'lib/thumbnailer/remote_origin'


run Thumbnailer::FileOrigin::Run.new
