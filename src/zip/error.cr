module Zip
  # Wrapper for exceptions raised by most `Archive` and `File` methods.
  class Error < Exception
    # Internal wrapper to create a new `Error` by wrapping an
    # `ErrorCode` value.
    protected def initialize(@code : ErrorCode)
      # puts "error code = #{@code}"
      super(@code.message)
    end

    # Internal wrapper to create a new `Error` from arbitrary integer
    # value *num*.
    protected def initialize(num : Int32)
      @code = ErrorCode.new(num)
      super(@code.message)
    end
  end
end
