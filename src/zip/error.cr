module Zip
  class Error < Exception
    def initialize(@code : ErrorCode)
      # puts "error code = #{@code}"
      super(@code.message)
    end

    def initialize(num : Int32)
      @code = ErrorCode.new(num)
      super(@code.message)
    end
  end
end
