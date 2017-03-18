# frozen_string_literal: true

module Application
  class Config
    def root_path
      File.expand_path(ENV['ZZMV_SOURCES_PATH'] || 'sources')
    end

    def thumbnails_root_path
      File.expand_path(ENV['ZZMV_THUMBNAILS_PATH'] || 'thumbnails')
    end
  end

  def self.config
    @config ||= Config.new
  end
end
