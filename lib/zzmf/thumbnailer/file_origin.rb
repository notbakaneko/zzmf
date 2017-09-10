# frozen_string_literal: true

require 'rack'
require 'rack/server'
require_relative '../magic_number'
require_relative '../thumbnails/image'
require_relative '../profiler'

module Zzmf
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
          validate!(request)
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
          mime_type = Zzmf::MagicNumber.from_string(buffer).mime_type
          response.headers['Content-Type'] = mime_type
          response.write(buffer)
          response.finish
        end

        def serve_file(filename)
          # FIXME: support SendFile
          response = Rack::Response.new
          body = File.binread(filename)
          mime_type = Zzmf::MagicNumber.from_string(body).mime_type
          response.headers['Content-Type'] = mime_type
          response.write(body)
          response.finish
        end

        def signature
          # force jpg everything
          "#{File.basename(request.path_info, '.*')}.jpg"
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
          Action.new(request).call
        rescue StandardError => e
          $stderr.puts e
          $stderr.puts e.backtrace
          headers = { 'Content-Type' => 'text/plain' }
          [500, headers, ['500 Internal Server Error']]
        # ensure
        #   GC.start(full_mark: false, immediate_sweep: false)
        end
      end
    end
  end
end
