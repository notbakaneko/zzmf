# frozen_string_literal: true

require 'psych'

module Zzmf
  module Config #:nodoc:
    module Icc
      def self.config_path
        ENV['ZZMF_ICC_PROFILES'] || File.join('config', 'icc')
      end

      def self.profile_path(profile)
        profile = profile.to_s
        File.absolute_path(File.join(config_path, config[profile]))
      end

      def self.config
        @config ||= reload_yaml || {}
      end

      def self.reload_yaml
        nodes = read_config
        nodes&.to_ruby
      end

      def self.read_config
        file = File.absolute_path(File.join(Zzmf::Config::Icc.config_path, 'icc.yml'))
        return unless File.exist?(file)
        Psych.parse_file(file)
      end
    end
  end
end
