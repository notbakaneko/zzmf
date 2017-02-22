# frozen_string_literal: true

require 'rack'
require 'rack/server'
require 'mime/types'
require_relative '../thumbnails/image'

module Thumbnailer
  module FileOrigin
    class Run
      def initialize
        $stdout.puts 'Using'
        $stdout.puts "  root_path: #{Application.config.root_path}"
        $stdout.puts "  thumbnails_root_path: #{Application.config.thumbnails_root_path}"
      end

      def call(env)
        Action.new(env).call
      rescue StandardError => e
        $stderr.puts e
        $stderr.puts e.backtrace
        headers = { 'Content-Type' => 'text/plain' }
        [500, headers, ['500 Internal Server Error']]
      end
    end

    class Action
      attr_reader :request

      def initialize(env)
        @request = ::Rack::Request.new(env)
      end

      def call
        log_str = "#{request.request_method} #{request.path} #{request.path_info} #{request.params}"
        $stdout.puts "Start #{log_str}"

        filename = profile(log_str) do
          return [404,  { 'Content-Type' => 'text/plain' }, ['404 Not Found']] unless File.file?(in_filename)

          # signature ||= file_digest(in_filename) if Application.config.auto_signature?
          thumbnailer = Thumbnails::Image.new(in_filename: in_filename, signature: signature)
          thumbnailer.find_or_create!(force: true, **opts)
        end
        serve_file(File.join(Application.config.thumbnails_root_path, filename))
      end

      def opts
        @opts ||= begin
                    hash = {}
                    hash[:q] = request.params['q'].to_i if request.params['q']
                    hash[:size] = request.params['l'] if request.params['l']

                    hash
                  end
      end

      def in_filename
        @in_filename ||= File.join(Application.config.root_path, request.path_info)
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
        request.params['signature']
      end

      def profile(name)
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        yield if block_given?
      ensure
        elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
        $stdout.puts "Completed #{name} in #{(elapsed * 100).round(6)} ms"
      end

      def file_digest(filename)
        warn "Calculating auto-signature for #{filename}"
        Digest::SHA256.file(filename).hexdigest
      end

    end
  end
end
