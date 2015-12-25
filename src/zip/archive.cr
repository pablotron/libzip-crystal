require "./flags"

module Zip
  class Archive
    protected getter zip
     
    # Create `Archive` instance from file *path*, pass instance to the
    # given block *block*, then close the archive when the block exits.
    #
    # See Also:
    # * `#create(String, Int32)`
    def self.open(path : String, flags = 0 : Int32, &block)
      # create archive
      zip = new(path, flags)

      r = nil
      begin
        # pass archive to block
        r = yield zip
      ensure
        # close archive
        zip.close if zip.open?
      end

      # return result
      r
    end

    # Default flags for `Archive#create`
    CREATE_FLAGS = (Flags::Open::CREATE | Flags::Open::EXCL).value

    # Create `Archive` instance from file *path*, pass the instance to
    # the given block *block*, then close the archive when the block
    # exits.
    #
    # See Also:
    # * `#open(String, Int32)`
    def self.create(path : String, flags = CREATE_FLAGS : Int32, &block)
      self.open(path, flags) do |zip|
        yield zip
      end
    end

    # Create `Archive` instance from file *path*.
    #
    # See Also:
    # * `#open(String, Int32)`
    def self.create(path : String, flags = CREATE_FLAGS : Int32)
      new(path, flags)
    end

    # Internal constructor to create `Archive` instance from
    # `LibZip::ZipArchive` and error code.
    protected def initialize(@zip : LibZip::ZipArchive, err : Int32)
      @comment = ""
      raise Error.new(err) unless @zip != nil && ok?(err)
      @open = true
    end

    # Create a `Archive` instance from the file *path*.
    def initialize(path : String, flags = 0 : Int32)
      # open from path
      zip = LibZip.zip_open(path, flags, out err)
      initialize(zip, err)
    end

    # Returns `Archive` instance from `IO::FileDescriptor` *fd*.
    def initialize(fd : IO::FileDescriptor, flags = 0 : Int32)
      # open from fd
      zip = LibZip.zip_fdopen(fd.fd, flags, out err)
      initialize(zip, err)
    end

    # Return last archive error as an `ErrorCode` instance.
    def error : ErrorCode
      assert_open

      LibZip.zip_error_get(@zip, out err, out sys)

      if err != 0 && sys != 0
        # TODO: do something with sys error?
        # puts "sys: #{sys}"
      end

      ErrorCode.new(err)
    end

    # Clear last archive error code.
    def clear_error
      assert_open

      LibZip.zip_error_clear(@zip)
      nil
    end

    # Returns *true* if this `Archive` is open, or *false* otherwise.
    def open?
      @open
    end

    # Close this `Archive`.  If *discard* is true, then discard any
    # changes.
    #
    # See also: `#discard`.
    def close(discard = false : Bool)
      assert_open

      if discard
        # discard changes
        LibZip.zip_discard(@zip)
      else
        # close archive
        err = LibZip.zip_close(@zip) 
        raise Error.new(err) unless ok?(err)
      end

      # mark as closed
      @open = false
    end

    # Discard any changes and close this `Archive`.  Equivalent to
    # `#close(true)`.
    #
    # See also: `#close`.
    def discard
      close(true)
    end

    # Set the comment for the entire archive.  Comment must be encoded
    # in ASCII or UTF-8.  Returns comment string.
    def comment=(s : String) : String
      assert_open

      if LibZip.zip_set_archive_comment(@zip, s, s.bytesize) == -1
        raise Error.new(error)
      end
      
      # retain and return
      @comment = s
    end

    # Returns comment for the entire archive.
    def comment(flags = 0 : Int32) : String
      assert_open

      ptr = LibZip.zip_get_archive_comment(@zip, out len, flags)
      String.new(ptr, len)
    end

    # Add entry *path* to archive from given `Source` *source* and
    # return index of new entry.
    #
    # See also: `#add(String, String, Int32)`.
    def add(path : String, source : Source, flags = 0 : Int32)
      assert_open

      # add file
      r = LibZip.zip_file_add(@zip, path, source.source, flags) == -1
      raise Error.new(error) if r == -1

      # return result
      r
    end

    # Add archive entry *path* with content *body*.
    #
    # See also: `#add(String, Source, Int32)`.
    def add(name : String, body : String)
      add(name, Source.from_buffer(self, body))
    end

    # Add directory to archive at path *path*.
    def add_dir(path : String, flags : Int32)
      assert_open

      # add dir, check for error
      r = LibZip.zip_dir_add(@zip, path)
      raise Error.new(r) if r == -1

      # return index
      r
    end

    # Replace entry at index *index* with `Source` *source*.
    #
    # See also: 
    # * `#replace(UInt64, String, Int32)`
    # * `#replace(String, Source, Int32)`
    # * `#replace(String, String, Int32)`
    def replace(index : UInt64, source : Source, flags = 0 : Int32)
      assert_open

      if LibZip.zip_file_replace(@zip, path, source.source, flags) == -1
        raise Error.new(error)
      end
    end

    # Replace entry at path *path* with `Source` *source*.
    #
    # See also: 
    # * `#replace(UInt64, Source, Int32)`
    # * `#replace(String, Source, Int32)`
    # * `#replace(String, String, Int32)`
    def replace(path : String, source : Source, flags = 0 : Int32)
      assert_open

      # get offset
      ofs = name_locate(path)
      raise Exception.new("unknown path: #{path}") if ofs == -1

      replace(ofs, source, flags)
    end

    # Replace entry at index *index* with contents *body*.
    #
    # See also: 
    # * `#replace(UInt64, Source, Int32)`
    # * `#replace(String, Source, Int32)`
    # * `#replace(String, String, Int32)`
    def replace(index : UInt64, body : String, flags = 0 : Int32)
      replace(index, Source.from_buffer(self, body), flags)
    end

    # Replace entry at path *path* with contents *body*.
    #
    # See also: 
    # * `#replace(UInt64, Source, Int32)`
    # * `#replace(String, Source, Int32)`
    # * `#replace(UInt64, String, Int32)`
    def replace(path : String, body : String, flags  = 0 : Int32)
      replace(path, Source.from_buffer(self, body), flags)
    end

    # Rename file at *index* to path *new_path*.
    def rename(index : UInt64, new_path : String, flags = 0 : Int32)
      assert_open

      err = LibZip.zip_file_rename(@zip, index, new_path, flags)
      raise Error.new(err) if err == -1

      nil
    end

    # Rename file named *old_path* to new path *new_path*.
    def rename(old_path : String, new_path : String, flags = 0 : Int32)
      rename(name_locate(old_path), new_path, flags)
    end

    # Delete file at given index *index*.
    def delete(index : UInt64)
      assert_open

      err = LibZip.zip_delete(@zip, index)
      raise Error.new(error) if err == -1

      nil
    end

    # Delete file at given path *path*.
    def delete(path : String)
      assert_open
      delete(name_locate(path))
    end

    # Returns index of given *path*, or -1 if the given path could not
    # be found.
    def name_locate(path : String, flags = 0 : Int32)
      assert_open

      LibZip.zip_name_locate(@zip, path, flags)
    end

    # Returns path of given *index*, or nil if there was an error or the
    # given index could not be found.
    def get_name(index : UInt64, flags : Int32) : String
      LibZip.zip_get_name(@zip, index, flags)
    end

    # Returns `File` instance of given *path* in `Archive`.
    def open(path : String, flags = 0 : Int32, password = nil : String?) : File
      assert_open

      # open file
      r = if password != nil
        LibZip.zip_fopen_encrypted(@zip, path, flags, password)
      else
        LibZip.zip_fopen(@zip, path, flags)
      end

      # check for error
      raise Error.new(error) if r == nil

      # return result
      File.new(self, r)
    end

    # Opens given *path* in `Archive` as a `File` instance, passes it to
    # block *block*, and closes the file when the block exits.
    def open(path : String, flags = 0 : Int32, password = nil : String?, &block)
      assert_open

      # open file
      f = open(path, flags, password)

      r = nil
      begin
        # yield file to block
        r = yield f
      ensure
        # close file if it is open
        f.close if f.open?
      end
        
      # return result
      r
    end

    # Returns `File` instance of given index *index* in `Archive`.
    def open(index : UInt64, flags = 0 : Int32, password = nil : String?)
      assert_open

      # open file
      r = if password != nil
        LibZip.zip_fopen_index_encrypted(@zip, index, flags, password)
      else
        LibZip.zip_fopen_index(@zip, index, flags)
      end

      # check for error
      raise Error.new(error) if r == nil

      # return result
      File.new(self, r)
    end

    # Opens index *index* in `Archive` as a `File` instance, passes it
    # to block *block*, and closes the file when the block exits.
    def open(index : UInt64, flags = 0 : Int32, password = nil : String?, &block)
      assert_open

      # open file
      f = open(index, flags)

      r = nil
      begin
        # yield file to block
        r = yield f
      ensure
        # close file if it is open
        f.close if f.open?
      end
        
      # return result
      r
    end

    # Set the default password used when accessing encrypted files, or
    # nil for no password.
    def default_password=(password : String?)
      r = LibZip.zip_set_default_password(@zip, password)
      raise Error.new(error) if r == -1
      password
    end

    # private methods

    private def assert_open
      raise "Archive already closed" unless open?
    end

    private def ok?(err : Int32)
      err == ErrorCode::OK.value
    end
  end
end
