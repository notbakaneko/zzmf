# frozen_string_literal: true

module Thumbnails
  require_relative 'vips'

  class Image
    include ::Thumbnails::Vips
    attr_accessor :signature, :in_file

    def initialize(in_file:, signature:, **opts)
      raise ArgumentError, 'signature must be longer than 2 characters' unless signature && signature.length > 1
      @in_file = File.absolute_path(in_file)
      @signature = signature
    end

    def exist?
      full_path.exist?
    end

    def find_or_create!(size: 900, q: 75)
      if full_path.exist?
        filename
      else
        create!(size: size, q: q)
      end
    end

    def delete!
      File.delete(full_path) if exist?
    end

    def filename
      "fsi/#{signature[0..1]}/#{signature}.jpg"
    end

    def full_path
      @full_path ||= Pathname.new(Application.config.thumbnails_root_path).join(filename)
    end

    private

    def basename
      File.basename(@in_file, '.*')
    end

    def ext
      File.extname(@in_file)
    end
  end
end
