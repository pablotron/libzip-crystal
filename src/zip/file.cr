module Zip
  # Thin `IO` wrapper for files in archives.
  class File
    include IO

    # Internal method to create a `File` instance.
    #
    # See Also:
    # * `Archive#open`
    protected def initialize(@zip : Archive, @file : LibZip::ZipFile)
      @open = true
    end

    # Returns true if this `File` is open, and false otherwise.
    def open?
      @open
    end

    # Close this `File` instance.
    def close
      assert_open
      
      # close file, check for error
      err = LibZip.zip_fclose(@file) 
      raise Zip::Error.new(err) if err != 0

      # flag instance as closed
      @open = false

      # return nil
      nil
    end

    # Read bytes into `Slice` *slice* and return number of bytes read
    # (or -1 on error).
    def read(slice : Slice(UInt8))
      assert_open
      LibZip.zip_fread(@file, slice, slice.bytesize)
    end

    def write(slice : Slice(UInt8))
      raise "cannot write to Zip::File instances"
    end

    # Return last archive error as an `ErrorCode` instance.
    def error : ErrorCode
      assert_open

      LibZip.zip_file_error_get(@file, out err, out sys)

      if err != 0 && sys != 0
        # TODO: do something with sys error?
        # puts "sys: #{sys}"
      end

      ErrorCode.new(err)
    end


    private def assert_open
      raise "archive closed" unless zip.open?
      raise "file closed" unless open?
    end
  end
end
