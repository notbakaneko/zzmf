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
      log_str = "#{request.request_method} #{request.path} #{request.path_info} #{request.params}"
      $stdout.puts "Start #{log_str}"

      filename = profile(log_str) do
        signature = request.params['signature']
        in_file = File.join(Application.config.root_path, request.path)
        return [404,  { 'Content-Type' => 'text/plain' }, ['404 Not Found']] unless File.file?(in_file)

        signature ||= file_digest(in_file) if Application.config.auto_signature?
        thumbnailer = Thumbnails::Image.new(in_file: in_file, signature: signature)
        thumbnailer.find_or_create!
      end
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

run Application::Runner.new
