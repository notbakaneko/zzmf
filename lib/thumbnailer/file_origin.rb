# frozen_string_literal: true

require 'rack'
require 'rack/server'
require 'mime/types'
require_relative '../thumbnails/image'
require_relative '../profiler'

module Thumbnailer
  module FileOutput
    def call
      super
      filename = Profiler.profile('Thumbnailer::FileOutput') do
        # signature ||= file_digest(in_filename) if Application.config.auto_signature?
        thumbnailer = Thumbnails::FromFile.new(input: in_filename, signature: signature)
        # thumbnailer.find_or_create!(force: true, **opts)
        thumbnailer.create!(size: opts[:size], quality: opts[:q], target: :file)
      end
      serve_file(File.join(Application.config.thumbnails_root_path, filename))
    end
  end

  module BufferOutput
    def call
      super
      output = Profiler.profile('Thumbnailer::BufferOutput') do
        thumbnailer = Thumbnails::FromFile.new(input: in_filename, signature: signature)
        thumbnailer.create!(size: opts[:size], quality: opts[:q], target: :buffer)
      end
      serve_binary(output)
    end
  end

  module FileOrigin
    class Action
      attr_reader :request

      def initialize(env)
        @request = ::Rack::Request.new(env)
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
                    hash[:size] = request.params['l'] if request.params['l']

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
        request.params['signature']
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
        Action.new(env).call
      rescue StandardError => e
        $stderr.puts e
        $stderr.puts e.backtrace
        headers = { 'Content-Type' => 'text/plain' }
        [500, headers, ['500 Internal Server Error']]
      end
    end
  end
end

# Thumbnailer::FileOrigin::Action.send(:prepend, Thumbnailer::FileOutput)
Thumbnailer::FileOrigin::Action.send(:prepend, Thumbnailer::BufferOutput)
