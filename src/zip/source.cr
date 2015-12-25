
module Zip
  class Source
    getter source

    def self.from_buffer(zip : Archive, s : String)
      # build source
      source = LibZip.zip_source_buffer(zip.zip, s, s.bytesize, 0)

      # build and return instance
      new(zip, source)
    end

    def self.from_buffer(zip : Archive, s : String, &block)
      r = from_buffer(zip, s)
      yield r
      r.free

      nil
    end

    def self.from_file(zip : Archive, path : String, offset = 0 : UInt64, len = -1 : Int64)
      source = LibZip.zip_source_file(zip.zip, path, offset, len)
      new(zip, source)
    end

    def self.from_file(
      zip         : Archive,
      path        : String,
      offset = 0  : UInt64, 
      len = -1    : Int64, 
      &block
    )
      r = from_file(zip, path, offset, len)
      yield r
      r.free

      nil
    end
      
    def initialize(zip : Archive, @source : LibZip::ZipSource?)
      unless @source
        raise Error.new(zip.error)
      end
    end
  end
end
