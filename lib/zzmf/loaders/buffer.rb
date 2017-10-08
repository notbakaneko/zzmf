# frozen_string_literal: true

require_relative '../thumbnails/image'

module Zzmf
  module Loaders
    # Provides a standard interface for callers to initialize a thumbnailer instance reads from a file
    module Buffer
      def new_thumbnailer
        Zzmf::Thumbnails::FromBuffer.new(input: origin_data, **opts)
      end
    end
  end
end
