# frozen_string_literal: true

module Zzmf
  module Thumbnailer
    class BaseAction
      attr_reader :request

      def initialize(request)
        @request = request
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

      def signature
        # force jpg everything
        "#{File.basename(request.path_info, '.*')}.jpg"
      end

      def use_cached?
        !request.params['force'] || request.params['force'].empty?
      end

      # FIXME: should be in output module
      def serve_binary(buffer)
        response = Rack::Response.new
        mime_type = Zzmf::MagicNumber.from_string(buffer).mime_type
        response.headers['Content-Type'] = mime_type
        response.write(buffer)
        response.finish
      end

      # FIXME: should be in output module
      def serve_file(filename)
        # FIXME: support SendFile
        response = Rack::Response.new
        body = File.binread(filename)
        mime_type = Zzmf::MagicNumber.from_string(body).mime_type
        response.headers['Content-Type'] = mime_type
        response.write(body)
        response.finish
      end
    end
  end
end
