# frozen_string_literal: true

require_relative 'vips'

module Zzmf
  module Thumbnails
    class Base
      DEFAULT_SCALE = 1.5

      include Thumbnails::Vips
      attr_accessor :input

      def initialize(input:, **opts)
        @input = input
        @scale = opts[:scale] || DEFAULT_SCALE
        @upscale = opts[:upscale] || false
        @fit = opts[:fit]&.to_sym
      end
    end

    class FromFile < Base
      def open_input(input, shrink: 1)
        open_file(filename: input, shrink: shrink)
      end
    end

    class FromBuffer < Base
      def open_input(input, shrink: 1)
        open_buffer(buffer: input, shrink: shrink)
      end
    end
  end
end
