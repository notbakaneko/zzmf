# frozen_string_literal: true

require 'rack'
require 'rack/server'
require 'net/http'
require 'uri'
require_relative '../config/icc'
require_relative '../magic_number'
require_relative '../thumbnails/image'
require_relative '../profiler'

module Zzmf
  module Thumbnailer
    class RemoteOrigin
      class Action
        attr_reader :request

        def initialize(request)
          @request = request
        end

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

        def create_opts
          @create_opts ||= begin
                             hash = {}
                             hash[:quality] = request.params['q'].to_i if request.params['q']
                             if request.params['l']
                               hash[:width] = hash[:height] = request.params['l'].to_i
                             else
                               hash[:width] = request.params['w'].to_i
                               hash[:height] = request.params['h'].to_i
                             end

                             hash[:strip] = request.params['strip'] != '0'

                             profile = request.params['profile']
                             if profile && !profile.empty?
                               hash[:profile] = File.absolute_path(Zzmf::Config::Icc.profile_path(profile))
                             end

                             hash
                           end
        end

        def opts
          @opts ||= begin
                      hash = {}
                      hash[:profile] = request.params['profile']
                      hash[:scale] = request.params['s'].to_f if request.params['s']
                      hash[:upscale] = request.params['u'] == '1'

                      hash
                    end
        end

        def origin_data
          @origin_data ||= fetch_origin(request.path_info)
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
