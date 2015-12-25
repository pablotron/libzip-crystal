module Zip
  # Abstract base source for a `Archive#add` or `Archive#replace`.
  class Source
    protected getter source

    protected def initialize(zip : Archive, @source : LibZip::ZipSource?)
      unless @source
        raise Error.new(zip.error)
      end
    end
  end

  # Use string as a source for a `Archive#add` or `Archive#replace`.
  class StringSource < Source
    def initialize(zip : Archive, s : String)
      super(zip, LibZip.zip_source_buffer(zip.zip, s, s.bytesize, 0))
    end
  end

  # Use slice as a source for a `Archive#add` or `Archive#replace`.
  class SliceSource < Source
    def initialize(zip : Archive, s : Slice)
      super(zip, LibZip.zip_source_buffer(zip.zip, s, s.bytesize, 0))
    end
  end

  # Use file as a source for a `Archive#add` or `Archive#replace`.
  class FileSource < Source
    def initialize(
      zip         : Archive,
      path        : String,
      offset = 0  : UInt64,
      len = -1    : Int64
    )
      super(zip, LibZip.zip_source_file(zip.zip, path, offset, len))
    end
  end
end
