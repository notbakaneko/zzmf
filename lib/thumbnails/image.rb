# frozen_string_literal: true

module Thumbnails
  require_relative 'vips'

  class Base
    include ::Thumbnails::Vips
    attr_accessor :signature, :input

    def initialize(input:, signature:, **_opts)
      raise ArgumentError, 'signature must be longer than 2 characters' unless signature && signature.length > 1
      @input = input
      @signature = signature
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
