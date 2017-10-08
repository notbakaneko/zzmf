# frozen_string_literal: true

require 'rack'
require 'rack/server'
require 'net/http'
require 'uri'
require_relative './base_action'
require_relative '../config/icc'
require_relative '../magic_number'
require_relative '../thumbnails/image'
require_relative '../profiler'

module Zzmf
  module Thumbnailer
    class RemoteOrigin
      class Action < ::Zzmf::Thumbnailer::BaseAction
        def call
          log_str = "#{request.request_method} #{request.path} #{request.path_info} #{request.params}"
          $stdout.puts "Start #{log_str}"
          validate!(request)

          return [404, { 'Content-Type' => 'text/plain' }, ['404 Not Found']] unless origin_data
          nil
        end

        def fetch_origin(path)
          # trim leading /
          path = path[1..-1] if path.start_with?('/')
          uri = URI.join(Application.config.remote_origin, path)
          res = Net::HTTP.get_response(uri)
          res.body
        end

        def origin_data
          @origin_data ||= fetch_origin(request.path_info)
        end
      end

      class Run
        def initialize
          $stdout.puts 'Using'
          $stdout.puts "  origin: #{Application.config.remote_origin}"
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
