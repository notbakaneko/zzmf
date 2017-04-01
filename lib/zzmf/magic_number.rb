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
      @mime_type ||= case partial[0..1].unpack('H*').first
                     when 'ffd8'
                       'image/jpeg'
                     when '47494638'
                       'image/gif'
                     when '89504e47'
                       'image/png'
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
