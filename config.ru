# frozen_string_literal: true

require_relative 'config/application'

require 'rack'
require 'rack/server'
require 'mime/types'
require_relative 'lib/thumbnails/image'

module Application
  class Runner
    def call(env)
      request = ::Rack::Request.new(env)
      $stdout.puts "#{request.request_method} #{request.path} #{request.path_info} #{request.params}"
      signature = request.params['signature']
      in_file = File.join(Application.config.root_path, request.path)
      return [404,  { 'Content-Type' => 'text/plain' }, ['404 Not Found']] unless File.exist?(in_file)

      signature ||= file_digest(in_file) if Application.config.auto_signature?
      thumbnailer = Thumbnails::Image.new(in_file: in_file, signature: signature)
      filename = thumbnailer.find_or_create!
      serve_file(File.join(Application.config.thumbnails_root_path, filename))
    rescue StandardError => e
      $stderr.puts e
      $stderr.puts e.backtrace
      headers = { 'Content-Type' => 'text/plain' }
      [500, headers, ['500 Internal Server Error']]
    end

    private

    def serve_file(filename)
      # FIXME: support SendFile
      response = Rack::Response.new
      body = File.binread(filename)
      mime = MIME::Types.type_for(filename)
      response.headers['Content-Type'] = mime.first
      response.write(body)
      response.finish
    end

    def file_digest(filename)
      warn "Calculating auto-signature for #{filename}"
      Digest::SHA256.file(filename).hexdigest
    end
  end
end

run Application::Runner.new
