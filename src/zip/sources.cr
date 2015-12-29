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
  # ### Example
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
    # ### Example
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
  # ### Example
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
    # ### Example
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
  # ### Example
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
    # ### Example
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
  # ### Example
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
    # ### Example
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
    # ### Example
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

  # Use arbitrary proc as data source for an `Archive#add` or
  # `Archive#replace`.  The `ProcSource#new` takes the following
  # arguments:
  #
  # * *zip*: Destination `Archive`.
  # * *proc*: Proc used for file operations.  See below for arguments.
  # * *user_data*: `Void*` pointer for user data passed to proc.
  #
  # ### Proc Arguments
  # * *action*: `Action` indicating which action the proc should perform (see "Actions" below).
  # * *slice*: Data slice used by the _READ_, _STAT_, and _ERROR_ `Action`s.
  # * *user_data*: *user_data* from above.  Used to pass data to proc.
  #
  # ### Actions
  # * `Action::OPEN`: Prepare for reading.  Return 0 on succes, or -1 on error.
  # * `Action::READ`: Read data into `slice`.  Return the number of bytes read, or -1 on error.
  # * `Action::CLOSE`: Reading is done.  Return 0.
  # * `Action::STAT`: Get meta information for input data.  `slice` points to an allocated `LibZip::Stat` structure.  Return ```sizeof(Zip::LibZip::Stat)``` on success, or -1 on error.
  # * `Action::ERROR`: Get error information.  `slice` points to an array of `LibC::Int` values which should be filled in with the corresponding `ErrorCode` and (if applicable) system error code.  Return ```2 * sizeof(LibC::Int)```.
  # * `Action::FREE`: Clean up resources.  Return 0.
  #
  # ### Example
  #
  #     # sample string data
  #     TEST_STRING = "This is a test string."
  #
  #     class TestProcSource < Zip::ProcSource
  #       property pos
  #       property data
  #
  #       def initialize(zip, data)
  #         # reset position and cache data slice
  #         @pos = 0
  #         @data = data.to_slice
  #
  #         super(zip, ->(
  #           action    : Zip::Action,
  #           slice     : Slice(UInt8),
  #           user_data : Void*) {
  #           # cast data pointer back to "self"
  #           me = user_data as TestProcSource
  #
  #           # switch on action, then coerce result to i64
  #           0_i64 + case action
  #           when .open?
  #             # reset position
  #             me.pos = 0
  #
  #             # return 0
  #             0
  #           when .read?
  #             if me.pos < data.bytesize
  #               # get shortest length
  #               len = me.data.bytesize - me.pos
  #               len = slice.bytesize if slice.bytesize < len
  #
  #               if len > 0
  #                 # copy string data to slice and increment position
  #                 slice.copy_from(me.data[me.pos, len].to_unsafe, len)
  #                 me.pos += len
  #               end
  #
  #               # return length
  #               len
  #             else
  #               # puts "read: done"
  #               0
  #             end
  #           when .stat?
  #             # get size of stat struct
  #             st_size = sizeof(Zip::LibZip::Stat)
  #
  #             # create and populate stat struct
  #             st = Zip::LibZip::Stat.new(
  #               valid:  Zip::StatFlag::SIZE.value,
  #               size:   me.data.bytesize
  #             )
  #
  #             # copy populated struct to slice
  #             slice.copy_from(pointerof(st) as Pointer(UInt8), st_size)
  #
  #             # return sizeof stat
  #             st_size
  #           else
  #             # for all other actions, do nothing
  #             0
  #           end
  #         }, self as Pointer(Void))
  #       end
  #     end
  #
  #     # populate zip with test files
  #     Zip::Archive.create("foo.zip") do |zip|
  #       # add "text.txt" from custom Zip::ProcSource
  #       zip.add("test.txt", TestProcSource.new(zip, TEST_STRING))
  #     end
  #
  class ProcSource < Source
    getter proc
    getter user_data

    # See `ProcSource` for example.
    def initialize(
      zip         : Archive,
      @proc       : Action, Slice(UInt8), Void* -> Int64,
      @user_data  : Void*
    )
      super(zip, LibZip.zip_source_function(zip.zip, wrap_proc, self as Void*))
    end

    private def wrap_proc
      ->(
        user_data     : Void*,
        data          : UInt8*,
        len           : UInt64,
        action_value  : Int32) do
        # get source, action, and slice
        source = user_data as ProcSource
        action = Action.new(action_value)
        slice = Slice(UInt8).new(data, len)

        # call real proc with action, slice, and data
        source.proc.call(action, slice, source.user_data)
      end
    end
  end
end
