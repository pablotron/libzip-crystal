module Zip
  # Abstract base source for `Archive#add` or `Archive#replace`.  You
  # cannot instantiate this class directly; use one of the subclasses
  # instead.
  class Source
    protected getter source

    # Internal `Source` constructor.
    protected def initialize(zip : Archive, @source : LibZip::ZipSource?)
      unless @source
        raise Error.new(zip.error)
      end
    end
  end

  # Use string as a source for `Archive#add` or `Archive#replace`.
  #
  # Example:
  #
  #     # create a new string source
  #     src = Zip::StringSource.new(zip, "test string")
  #
  #     # add to archive as "foo.txt"
  #     zip.add("foo.txt", src)
  #
  class StringSource < Source
    # Create a new `StringSource` from the given *string*.
    #
    # Example:
    #
    #     # create a new string source
    #     src = Zip::StringSource.new(zip, "test string")
    #
    #     # add to archive as "foo.txt"
    #     zip.add("foo.txt", src)
    #
    def initialize(zip : Archive, s : String)
      super(zip, LibZip.zip_source_buffer(zip.zip, s, s.bytesize, 0))
    end
  end

  # Use slice as a source for `Archive#add` or `Archive#replace`.
  #
  # Example:
  #
  #     # create slice
  #     slice = Slice.new(10) { |i| i + 10 }
  #
  #     # create source
  #     source = SliceSource.new(zip, slice)
  #
  #     # add slice to archive as "foo.txt"
  #     zip.add("foo.txt", source)
  #
  class SliceSource < Source
    # Create a new `SliceSource` from the given *slice*.
    #
    # Raises an exception if this `SliceSource` could not be created.
    #
    # Example:
    #
    #     # create slice
    #     slice = Slice.new(10) { |i| i + 10 }
    #
    #     # create source
    #     source = SliceSource.new(zip, slice)
    #
    #     # add slice to archive as "foo.txt"
    #     zip.add("foo.txt", source)
    #
    def initialize(zip : Archive, s : Slice)
      super(zip, LibZip.zip_source_buffer(zip.zip, s, s.bytesize, 0))
    end
  end

  # Use `IO::Descriptor` as source for an `Archive#add` or `Archive#replace`.
  #
  # TODO
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

  # Use file as a source for an `Archive#add` or `Archive#replace`.
  #
  # Example:
  #
  #     # create file source
  #     source = FileSource.new(zip, "/path/to/file.txt")
  #
  #     # add file to archive as "foo.txt"
  #     zip.add("foo.txt", source)
  #
  class FileSource < Source
    # Create file source for an `Archive#add` or `Archive#replace`.
    #
    # Raises an exception if `FileSource` could not be created.
    #
    # Example:
    #
    #     # create file source
    #     source = FileSource.new(zip, "/path/to/file.txt")
    #
    #     # add file to archive as "foo.txt"
    #     zip.add("foo.txt", source)
    #
    def initialize(
      zip         : Archive,
      path        : String,
      offset = 0  : UInt64,
      len = -1    : Int64
    )
      super(zip, LibZip.zip_source_file(zip.zip, path, offset, len))
    end
  end

  # Use file from another `Archive` as a source for an `Archive#add` or
  # `Archive#replace`.
  #
  # Example:
  #
  #     # open source archive
  #     Zip::Archive.open("foo.zip") do |src_zip|
  #       # open destination archive
  #       Zip::Archive.create("bar.zip") do |dst_zip|
  #         # create source from "some-file.txt" in "foo.zip"
  #         source = ArchiveSource.new(dst_zip, src_zip, "some-file.txt")
  #
  #         # add to destination archive as "foo.txt"
  #         zip.add("foo.txt", source)
  #       end
  #     end
  #
  class ArchiveSource < Source
    # Create ArchiveSource from source zip and source index.
    #
    # Raises an exception if `ArchiveSource` could not be created.
    #
    # Example:
    #
    #     # open source archive
    #     Zip::Archive.open("foo.zip") do |src_zip|
    #       # open destination archive
    #       Zip::Archive.create("bar.zip") do |dst_zip|
    #         # define index
    #         index = 0
    #
    #         # create source from index in "foo.zip"
    #         source = ArchiveSource.new(dst_zip, src_zip, index)
    #
    #         # add to destination archive as "foo.txt"
    #         zip.add("foo.txt", source)
    #       end
    #     end
    #
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

    # Create `ArchiveSource` from source zip and source path.
    #
    # Raises an exception if `ArchiveSource` could not be created.
    #
    # Example:
    #
    #     # open source archive
    #     Zip::Archive.open("foo.zip") do |src_zip|
    #       # open destination archive
    #       Zip::Archive.create("bar.zip") do |dst_zip|
    #         # create source from "some-file.txt" in "foo.zip"
    #         source = ArchiveSource.new(dst_zip, src_zip, "some-file.txt")
    #
    #         # add to destination archive as "foo.txt"
    #         zip.add("foo.txt", source)
    #       end
    #     end
    #
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

  # Use proc as source for an `Archive#add` or `Archive#replace`.
  # FIXME: this is almost certainly broken
  class ProcSource < Source
    STAT_SIZE = sizeof(LibZip::Stat)
    ERRS_SIZE = Int64.new(sizeof(LibC::Int) * 2)

    def self.handle(
      user_data : Void*,
      data      : Void*,
      len       : UInt64,
      action    : Int32
    ) : Int64
      source = Pointer(CustomSource).new(user_data.address) as CustomSource

      # wrap action
      a = CustomSourceAction.new(action)

      0_i64 + if a.open?
        source.source_open
      elsif a.read?
        source.source_read(Slice(UInt8).new(data, len))
      elsif a.close?
        source.source_close
        0 # always return 0
      elsif a.stat?
        source.source_stat(Pointer(LibZip::Stat).new(data.address))
        STAT_SIZE
      elsif a.error?
        slice = Slice(LibC::Int).new(Pointer(LibC::Int).new(data.address), 2)
        source.source_error(slice)
        ERRS_SIZE
      elsif a.free?
        source.source_free
        0_i64 # always return 0
      else
        # unknown action, return error
        -1
      end
    end


    # FIXME: this is almost certainly broken
    def initialize(
      zip       : Archive,
      proc      : Void*, UInt8*, UInt64, Int32 -> Int64,
      user_data : Void*
    )
      super(zip, LibZip.zip_source_function(zip.zip, proc, user_data))
    end
#
#
#     def source_open
#       0
#     end
#
#     def source_close()
#       # stub, do nothing
#     end
#
#     def source_read(slice : Slice(UInt8))
#       puts "in CustomSource#source_read"
#       0
#     end
#
#     def source_stat(ptr : Pointer(LibZip::Stat))
#       0
#     end
#
#     def source_error(errs : Slice(LibC::Int))
#       0
#     end
#
#     def source_free
#     end
#
  end
end
