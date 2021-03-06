# frozen_string_literal: true

# Module for thumbnailer output to buffer
module Zzmf
  module Thumbnailer
    module BufferOutput
      def call
        # FIXME
        result = super
        return result if result

        output = Profiler.profile('Thumbnailer::BufferOutput') do
          new_thumbnailer.create!(target: :buffer, **create_opts)
        end
        serve_binary(output)
      end
    end
  end
end
