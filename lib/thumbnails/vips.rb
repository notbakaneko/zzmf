# frozen_string_literal: true
require 'vips'
require_relative '../profiler'

module Thumbnails
  module Vips
    def create!(size: 900, quality: 75, target: :file, **args)
      # whitelist
      raise ArgumentError, 'target must be file or buffer' unless %i(file buffer).include?(target)
      send("create_to_#{target}!", size: size, quality: quality, **args)
    end

    def create_to_file!(filename:, size:, quality:, **)
      image = setup_pipeline(size: size, can_shrink: supports_shrink?(filename))
      Profiler.profile('write file') do
        image.write_to_file(filename, strip: true, Q: quality)
      end
    end

    def create_to_buffer!(size:, quality:, **)
      image = setup_pipeline(size: size)
      Profiler.profile('write buffer') do
        # FIXME: not jpg
        image.write_to_buffer('.jpg', strip: true, Q: quality)
      end
    end

    def load_factor(shrink:, scale:)
      factor = (shrink / scale).to_i
      return 1 if factor <= 1
      return 8 if factor > 8
      factor
    end

    def setup_pipeline(size:, can_shrink: true)
      image = open_file(filename: @input, shrink: 1)
      # image = open_buffer(buffer: @in_stream, shrink: 1)
      scale_d = d = [image.width, image.height].max
      shrink = d / size.to_f

      load_shrink = load_factor(shrink: shrink, scale: @scale)
      if load_shrink > 1 && can_shrink
        image = open_file(filename: @input, shrink: load_shrink)
        # image = open_buffer(buffer: @in_stream, shrink: load_shrink)
        scale_d = [image.width, image.height].max
      end

      rscale = size.to_f / scale_d
      # $stderr.puts "scaling #{@input} by #{shrink}, #{load_shrink}, #{rscale}, [#{image.width}, #{image.height}]"
      # image = image
      #         .tile_cache(image.width, 1, 30)
      #         .affinei_resize(:bicubic, rscale)

      # image = image.conv(SHARPEN_MASK) if load_shrink > 1
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
      filename.end_with?(*%w(jpg jpeg))
    end
  end
end
