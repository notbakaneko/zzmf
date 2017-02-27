# frozen_string_literal: true

require 'rack'
require 'rack/server'
require 'mime/types'
require_relative '../thumbnails/image'
require_relative '../profiler'

module Thumbnailer
  module FileOrigin
    class Action
      attr_reader :request

      def initialize(request)
        @request = request
      end

      def call
        log_str = "#{request.request_method} #{request.path} #{request.path_info} #{request.params}"
        $stdout.puts "Start #{log_str}"
        return [404, { 'Content-Type' => 'text/plain' }, ['404 Not Found']] unless File.file?(in_filename)
      end

      def opts
        @opts ||= begin
                    hash = {}
                    hash[:q] = request.params['q'].to_i if request.params['q']
                    hash[:size] = request.params['l'].to_i if request.params['l']
                    hash[:scale] = request.params['s'].to_f if request.params['s']

                    hash
                  end
      end

      def in_filename
        @in_filename ||= File.join(Application.config.root_path, request.path_info)
      end

      def serve_binary(buffer)
        response = Rack::Response.new
        body = buffer
        mime = MIME::Types.type_for('image/jpeg')
        response.headers['Content-Type'] = mime.first
        response.write(body)
        response.finish
      end

      def serve_file(filename)
        # FIXME: support SendFile
        response = Rack::Response.new
        body = File.binread(filename)
        mime = MIME::Types.type_for(filename)
        response.headers['Content-Type'] = mime.first
        response.write(body)
        response.finish
      end

      def signature
        File.basename(request.path_info)
        # request.params['signature']
      end

      def use_cached?
        !request.params['force'] || request.params['force'].empty?
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
        validate!(request)
        Action.new(request).call
      rescue StandardError => e
        $stderr.puts e
        $stderr.puts e.backtrace
        headers = { 'Content-Type' => 'text/plain' }
        [500, headers, ['500 Internal Server Error']]
      end

      private

      def validate!(request)
        # rubocop:disable Metrics/LineLength, Style/NumericPredicate
        # arbitrary
        raise ArgumentError, 'l must be > 0 and < 10000' unless request.params['l'] && request.params['l'].to_i > 0 && request.params['l'].to_i < 10_000
        raise ArgumentError, 'q must be >=0 and <= 100' unless request.params['q'] && request.params['q'].to_i >= 0 && request.params['q'].to_i <= 100
        raise ArgumentError, 's must be >=1 and <= 2' if request.params['s'] && request.params['s'].to_f < 1 && request.params['s'].to_f > 2
        rause ArgumentError, 'A filename is required' unless request.path_info && !request.path_info.empty?
        # rubocop:enable Metrics/LineLength, Style/NumericPredicate
      end
    end
  end
end
