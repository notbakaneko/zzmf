# frozen_string_literal: true

module Thumbnails
  require_relative 'vips'

  class Base
    DEFAULT_SCALE = 1.5

    include ::Thumbnails::Vips
    attr_accessor :input

    def initialize(input:, **opts)
      @input = input
      @scale = opts[:scale] || DEFAULT_SCALE
    end
  end

  class FromFile < Base
  end

  class FromBuffer < Base
  end
end
