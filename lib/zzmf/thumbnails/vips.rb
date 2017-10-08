# frozen_string_literal: true

require 'vips'
require_relative '../config/icc'
require_relative '../profiler'

module Zzmf
  module Thumbnails
    module Vips
      module OldLibJpegScale
        # scaling for lipjepg and libvips that only support
        # power of 2.
        def load_factor(shrink:, scale:)
          factor = (shrink / scale).to_i
          return 1 if factor <= 1
          return 8 if factor > 8
          factor -= 1
          factor |= factor >> 1
          factor |= factor >> 2
          factor += 1
          factor >> 1
        end
      end
      # use powers of 2 only scaling unless special flag is set.
      prepend OldLibJpegScale unless ENV['ZZMF_NEW_LIBJPEG']

      def create!(width:, height:, quality: 75, target: :file, **opts)
        # whitelist
        raise ArgumentError, 'target must be file or buffer' unless %i(file buffer).include?(target)
        send("create_to_#{target}!", width: width, height: height, quality: quality, **opts)
      end

      def create_to_file!(filename:, width:, height:, quality:, **opts)
        image = setup_pipeline(width: width, height: height, can_shrink: supports_shrink?(filename))
        opts.delete(:profile) if image.get_typeof('icc-profile-data') == 0

        image = icc_transform(image, opts)

        Profiler.profile('write file') do
          image.write_to_file(filename, Q: quality, **opts)
        end
      end

      def create_to_buffer!(width:, height:, quality:, **opts)
        image = setup_pipeline(width: width, height: height)
        opts.delete(:profile) if image.get_typeof('icc-profile-data') == 0

        image = icc_transform(image, opts)

        Profiler.profile('write buffer') do
          # FIXME: not jpg
          image.write_to_buffer('.jpg', Q: quality, **opts)
        end
      end

      def load_factor(shrink:, scale:)
        factor = (shrink / scale).to_i
        return 1 if factor <= 1
        return 8 if factor > 8
        factor
      end

      def setup_pipeline(width:, height:, can_shrink: true)
        image = open_input(@input, shrink: 1)
        size = size_cap(image, width, height)

        return image unless @upscale || ([image.width, image.height].max > size)

        # image = open_buffer(buffer: @in_stream, shrink: 1)
        scale_d = d = [image.width, image.height].max
        shrink = d / size.to_f

        load_shrink = load_factor(shrink: shrink, scale: @scale)
        if load_shrink > 1 && can_shrink
          image = open_input(@input, shrink: load_shrink)
          # image = open_buffer(buffer: @in_stream, shrink: load_shrink)
          scale_d = [image.width, image.height].max
        end

        rscale = size.to_f / scale_d
        # $stderr.puts "scaling #{@input} by #{shrink}, #{load_shrink}, #{rscale}, [#{image.width}, #{image.height}]"
        image = image.resize(rscale)

        image
      end
      # rubocop:enable Metrics/AbcSize

      SHARPEN_MASK = ::Vips::Image.new_from_array([
                                                    [-1, -1, -1],
                                                    [-1, 32, -1],
                                                    [-1, -1, -1]
                                                  ], 24, 0).freeze

      private

      def icc_transform(image, **opts)
        return image unless opts[:profile]

        image.icc_transform(
          opts[:profile],
          embedded: true
        )
      end

      def size_cap(image, width, height)
        scale = [image.width.to_f / width, image.height.to_f / height].max
        [image.width.to_f / scale, image.height.to_f / scale].max
      end

      def aspect_ratio(width, height)
        width.to_f / height.to_f
      end

      def open_buffer(buffer:, shrink: 1)
        ::Vips::Image.new_from_buffer(buffer, '', shrink: shrink)
      end

      def open_file(filename:, shrink: 1)
        if supports_shrink?(filename)
          ::Vips::Image.new_from_file(filename, shrink: shrink)
        else
          ::Vips::Image.new_from_file(filename)
        end
      end

      def supports_shrink?(filename)
        filename.end_with?(*%w(jpg jpeg)) # rubocop:disable Lint/UnneededSplatExpansion
      end
    end
  end
end
