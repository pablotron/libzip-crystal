module Zip
  # Abstract base source for `Archive#add` or `Archive#replace`.
  class Source
    protected getter source

    protected def initialize(zip : Archive, @source : LibZip::ZipSource?)
      unless @source
        raise Error.new(zip.error)
      end
    end
  end

  # Use string as a source for `Archive#add` or `Archive#replace`.
  class StringSource < Source
    def initialize(zip : Archive, s : String)
      super(zip, LibZip.zip_source_buffer(zip.zip, s, s.bytesize, 0))
    end
  end

  # Use slice as a source for `Archive#add` or `Archive#replace`.
  class SliceSource < Source
    def initialize(zip : Archive, s : Slice)
      super(zip, LibZip.zip_source_buffer(zip.zip, s, s.bytesize, 0))
    end
  end

  # Use `IO::Descriptor` as source for a `Archive#add` or `Archive#replace`.
  class DescriptorSource < Source
    def initialize(
      zip         : Archive,
      fd          : IO::Descriptor,
      offset = 0  : UInt64,
      len = -1    : Int64
    )
      fh = LibC.fdopen(fd.fd, "rb")
      raise "couldn't reopen descriptor" if fh == nil
      super(zip, LibZip.zip_source_filep(zip.zip, fh, offset, len))
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

  # Use file from anoter `Archive` as a source for a `Archive#add` or
  # `Archive#replace`.
  class ArchiveSource < Source
    # Create ArchiveSource from source zip and source index.
    def initialize(
      dst_zip     : Archive,
      src_zip     : Archive,
      src_idx     : UInt64,
      offset = 0  : UInt64,
      len = -1    : Int64,
      flags = 0   : Int32
    )
      super(dst_zip, LibZip.zip_source_zip(
        dst_zip.zip,
        src_zip.zip,
        src_idx,
        flags,
        offset,
        len
      ))
    end

    # Create ArchiveSource from source zip and source path.
    def initialize(
      dst_zip     : Archive,
      src_zip     : Archive,
      src_path    : String,
      offset = 0  : UInt64,
      len = -1    : Int64,
      flags = 0   : Int32
    )
      super(dst_zip, LibZip.zip_source_zip(
        dst_zip.zip,
        src_zip.zip,
        src_zip.name_locate(path),
        flags,
        offset,
        len
      ))
    end
  end

  # Use proc as source for a `Archive#add` or `Archive#replace`.
  # FIXME: this is almost certainly broken
  class ProcSource < Source
    def initialize(zip, block : -> )
      super(zip, LibZip.zip_source_function(zip.zip, block, nil));
    end
  end
end
