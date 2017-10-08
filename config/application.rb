# frozen_string_literal: true

module Application
  class Config
    def root_path
      File.expand_path(ENV['ZZMF_SOURCES_PATH'] || 'sources')
    end

    def thumbnails_root_path
      File.expand_path(ENV['ZZMF_THUMBNAILS_PATH'] || 'thumbnails')
    end
  end

  def self.config
    @config ||= Config.new
  end
end
