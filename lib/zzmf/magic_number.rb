# frozen_string_literal: true
module Zzmf
  class MagicNumber
    attr_reader :partial

    def self.from_string(str)
      new(str)
    end

    def self.from_io(io)
      io.rewind
      instance = new(io.read(4) || '') # read returns nil if it hits EOF at the start.
      io.rewind

      instance
    end

    def initialize(str)
      @partial = str
    end

    def mime_type
      @mime_type ||= begin
                       unpack = partial[0..3].unpack('H*').first
                       return 'image/jpeg' if unpack[0..3] == 'ffd8'

                       case unpack
                       when '47494638'
                         'image/gif'
                       when '89504e47'
                         'image/png'
                       end
                     end
    end

    def jpg?
      mime_type == 'image/jpeg'
    end

    def gif?
      mime_type == 'image/gif'
    end

    def png?
      mime_type == 'image/png'
    end
  end
end
