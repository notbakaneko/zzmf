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
    def find_or_create!(size: 900, q: 75, force: false, **args)
      # if full_path.exist? && !force
      #   filename
      # else
        create!(size: size, quality: q, **args)
      # end
    end

    # def exist?
    #   full_path.exist?
    # end
    #
    # def delete!
    #   File.delete(full_path) if exist?
    # end

    # private
    #
    # def basename
    #   File.basename(@input, '.*')
    # end
    #
    # def ext
    #   File.extname(@input)
    # end
  end

  class FromBuffer < Base
  end
end
