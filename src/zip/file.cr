module Zip
  # Thin `IO` wrapper for reading files from archives.  Use
  # `Archive#open` to get an instance.
  #
  # ### Example
  #
  #     # open "foo.txt" in archive
  #     str = zip.open("foo.txt") do |file|
  #       # build result string
  #       String.build |b|
  #         # read file in chunks
  #         file.read do |buf, len|
  #           b.write(buf[0, len])
  #         end
  #       end
  #     end
  #
  #     # print file contents
  #     puts "file contents: #{str}"
  #
  class File
    include IO

    # Internal method to create a `File` instance.  Use `Archive#open`
    # instead.
    protected def initialize(@zip : Archive, @file : LibZip::ZipFile)
      @open = true
    end

    # Returns true if this `File` is open, and false otherwise.
    #
    # ### Example
    #
    #     # is this file open?
    #     puts "file is open" if file.open?
    #
    def open?
      @open
    end

    # Close this `File` instance.
    #
    # Raises an exception if this `File` is not open.
    #
    # ### Example
    #
    #     # close file
    #     file.close
    #
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
    #
    # Raises an exception if this `File` is not open.
    #
    # ### Example
    #
    #     # create slice buffer
    #     buf = Slice(UInt8).new(10)
    #
    #     # read up to 10 bytes into buf and return number of bytes read
    #     len = file.read(buf)
    #
    def read(slice : Slice(UInt8))
      assert_open
      LibZip.zip_fread(@file, slice, slice.bytesize)
    end

    # Call proc with chunks of file, then return number of bytes read.
    #
    # Raises an exception if this `File` is not open.
    #
    # ### Example
    #
    #     # number of bytes read
    #     num_bytes = 0
    #
    #     # create string builder
    #     str = String.build do |b|
    #       # read chunks
    #       num_bytes = file.read do |buf, len|
    #         # add chunk to builder
    #         str.write(buf[0, len])
    #       end
    #     end
    #
    def read(&block : (Slice(UInt8), Int32) -> Nil) : UInt64
      # create buffer
      buf = Slice(UInt8).new(1024)
      sum = 0_u64

      # read chunks
      while ((len = read(buf)) > 0)
        block.call(buf, len)
        sum += len
      end

      # return result
      sum
    end

    # `File` instances are read-only so this method unconditionally
    # throws an `Exception`.
    def write(slice : Slice(UInt8))
      raise "cannot write to Zip::File instances"
    end

    # Return last archive error as an `ErrorCode` instance.
    #
    # Raises an exception if this `File` is not open.
    #
    # ### Example
    #
    #     # get and print last error
    #     puts file.error
    #
    def error : ErrorCode
      assert_open

      # get last error
      LibZip.zip_file_error_get(@file, out err, out unused)

      # wrap and return result
      ErrorCode.new(err)
    end

    # Return last system error for this file.
    #
    # Raises an exception if this `File` is not open.
    #
    # ### Example
    #
    #     # get and print last system error
    #     puts file.system_error
    #
    def system_error : LibC::Int
      assert_open

      # get system error
      LibZip.zip_file_error_get(@zip, nil, out r)

      # return result
      r
    end

    private def assert_open
      raise "archive closed" unless @zip.open?
      raise "file closed" unless open?
    end
  end
end
