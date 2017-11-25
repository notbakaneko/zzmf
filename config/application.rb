# frozen_string_literal: true

module Application
  class Config
    def root_path
      File.expand_path(ENV['ZZMF_ORIGIN'] || 'sources')
    end

    def thumbnails_root_path
      File.expand_path(ENV['ZZMF_THUMBNAILS_PATH'] || 'thumbnails')
    end

    def remote_origin
      ENV['ZZMF_ORIGIN'] || 'http://localhost/'
    end

    def origin
      ENV['ZZMF_ORIGIN'] || 'http://localhost/'
    end

    def origin_type
      remote_origin.start_with?('https://') || remote_origin.start_with?('http://') ? :remote : :file
    end
  end

  def self.config
    @config ||= Config.new
  end
end
