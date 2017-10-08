# frozen_string_literal: true

require_relative '../thumbnails/image'

module Zzmf
  module Loaders
    # Provides a standard interface for callers to initialize a thumbnailer instance that reads from a file
    module File
      def new_thumbnailer
        Zzmf::Thumbnails::FromFile.new(input: in_filename, **opts)
      end
    end
  end
end
