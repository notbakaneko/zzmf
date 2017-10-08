# frozen_string_literal: true

require 'rack'
require 'rack/server'
require_relative './base_action'
require_relative '../config/icc'
require_relative '../magic_number'
require_relative '../thumbnails/image'
require_relative '../profiler'

module Zzmf
  module Thumbnailer
    module FileOrigin
      class Action < ::Zzmf::Thumbnailer::BaseAction
        def call
          log_str = "#{request.request_method} #{request.path} #{request.path_info} #{request.params}"
          $stdout.puts "Start #{log_str}"
          return [404, { 'Content-Type' => 'text/plain' }, ['404 Not Found']] unless File.file?(in_filename)
          validate!(request)
        end

        def in_filename
          @in_filename ||= File.join(Application.config.root_path, request.path_info)
        end

        def file_digest(filename)
          warn "Calculating auto-signature for #{filename}"
          Digest::SHA256.file(filename).hexdigest
        end
      end

      class Run
        def initialize
          $stdout.puts 'Using'
          $stdout.puts "  root_path: #{Application.config.root_path}"
          $stdout.puts "  thumbnails_root_path: #{Application.config.thumbnails_root_path}"
        end

        def call(env)
          request = ::Rack::Request.new(env)
          Action.new(request).call
        rescue StandardError => e
          $stderr.puts e
          $stderr.puts e.backtrace
          headers = { 'Content-Type' => 'text/plain' }
          [500, headers, ['500 Internal Server Error']]
        end
      end
    end
  end
end
