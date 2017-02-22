# frozen_string_literal: true
require 'vips8'

module Thumbnails
  module Vips
    def create!(size: 900, quality: 75, **)
      FileUtils.mkdir_p File.dirname(full_path)
      image = setup_pipeline(size: size)
      write(image, quality)

      filename
    end

    def create(size:, quality:, **)
      image = setup_pipeline(size: size)
      image.write_to_buffer(ext, strip: true, Q: quality)
      write_to_buffer(image, quality)
    end

    def load_factor(shrink:)
      if shrink >= 8
        8
      elsif shrink >= 4
        4
      elsif shrink >= 2
        2
      elsif shrink >= 1
        1
      else
        1
      end
    end

    # rubocop:disable Metrics/AbcSize
    def setup_pipeline(size:)
      image = open_image(filename: @in_filename, shrink: 1)
      # image = open_buffer(@in_stream, shrink: 1)
      scale_d = d = [image.width, image.height].max
      shrink = d / size.to_f

      load_shrink = load_factor(shrink: shrink)
      if load_shrink > 1 && supports_shrink?(filename)
        image = open_image(filename: @in_filename, shrink: load_shrink)
        # image = open_buffer(@in_stream, shrink: load_shrink)
        scale_d = [image.width, image.height].max
      end

      rscale = size.to_f / scale_d
      # $stderr.puts "scaling #{@in_filename} by #{shrink}, #{load_shrink}, #{rscale}, [#{image.width}, #{image.height}]"
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

    def write(image, quality)
      image.write_to_file(full_path.to_s, strip: true, Q: quality)
    end

    def open_buffer(buffer, shrink: 1)
      ::Vips::Image.new_from_buffer(buffer, '', shrink: shrink, access: :sequential)
    end

    def thumb_open(filename, shrink = 1)
      # Rails.logger.debug("open #{filename}, shrink: #{shrink}")
      if supports_shrink?(filename)
        ::Vips::Image.new_from_file(filename, shrink: shrink, access: :sequential)
      else
        ::Vips::Image.new_from_file(filename, access: :sequential)
      end
    end

    def open_image(filename:, shrink: 1)
      thumb_open(filename, shrink)
    end

    def supports_shrink?(filename)
      filename.end_with?(*%w(jpg jpeg))
    end
  end
end
