# frozen_string_literal: true

# Module for thumbnailer to output to file.
module Thumbnailer
  module FileOutput
    def call
      super
      raise ArgumentError, 'signature must be longer than 2 characters' unless signature && signature.length > 1
      if !use_cached? || !File.file?(full_path)
        Profiler.profile('Thumbnailer::FileOutput') do
          FileUtils.mkdir_p File.dirname(full_path)
          # signature ||= file_digest(in_filename) if Application.config.auto_signature?
          thumbnailer = Thumbnails::FromFile.new(input: in_filename, signature: signature)
          # thumbnailer.find_or_create!(force: true, **opts)
          thumbnailer.create!(size: opts[:size], quality: opts[:q], target: :file, filename: full_path.to_s)
        end
      end
      serve_file(full_path.to_s)
    end

    private

    def filename
      "#{opts[:size]}/#{signature[0..1]}/#{signature}.jpg"
    end

    def full_path
      @full_path ||= Pathname.new(Application.config.thumbnails_root_path).join(filename)
    end
  end
end
