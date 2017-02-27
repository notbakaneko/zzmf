# frozen_string_literal: true

# Module for thumbnailer output to buffer
module Thumbnailer
  module BufferOutput
    def call
      super
      output = Profiler.profile('Thumbnailer::BufferOutput') do
        thumbnailer = Thumbnails::FromFile.new(input: in_filename, scale: opts[:scale])
        thumbnailer.create!(size: opts[:size], quality: opts[:q], target: :buffer)
      end
      serve_binary(output)
    end
  end
end
