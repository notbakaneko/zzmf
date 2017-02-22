# frozen_string_literal: true

module Application
  class Config
    def root_path
      File.expand_path('~/Pictures/i')
    end

    def thumbnails_root_path
      File.expand_path('~/Documents/projects/athena-thumbnailer/public')
    end

    def auto_signature?
      true
    end
  end

  def self.config
    @config ||= Config.new
  end
end
