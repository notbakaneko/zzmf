# frozen_string_literal: true

# Module for thumbnailer to output to file.
module Zzmf
  module Thumbnailer
    module FileOutput
      def call
        # FIXME
        result = super
        return result if result

        raise ArgumentError, 'signature must be longer than 2 characters' unless signature && signature.length > 1
        if !use_cached? || !File.file?(full_path)
          Profiler.profile('Thumbnailer::FileOutput') do
            FileUtils.mkdir_p File.dirname(full_path)

            new_thumbnailer.create!(target: :file, filename: full_path.to_s, **create_opts)
          end
        end
        serve_file(full_path.to_s)
      end

      private

      def filename
        "#{create_opts[:size]}/#{signature[0..1]}/#{signature}"
      end

      def full_path
        @full_path ||= begin
                         if opts[:profile]
                           File.join(Application.config.thumbnails_root_path, opts[:profile], opts_as_querystring, filename)
                         else
                           File.join(Application.config.thumbnails_root_path, 'default', opts_as_querystring, filename)
                         end
                       end
      end

      def opts_as_querystring
        pairs = create_opts.merge(opts).map do |k, v|
          "#{k}=#{v}"
        end
        pairs.join('&')
      end
    end
  end
end
