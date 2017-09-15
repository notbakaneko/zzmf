# frozen_string_literal: true

module Zzmf
  module Thumbnails
    require_relative 'vips'

    class Base
      DEFAULT_SCALE = 1.5

      include Thumbnails::Vips
      attr_accessor :input

      def initialize(input:, **opts)
        @input = input
        @scale = opts[:scale] || DEFAULT_SCALE
        @upscale = opts[:upscale] || false
      end
    end

    class FromFile < Base
    end

    class FromBuffer < Base
    end
  end
end
