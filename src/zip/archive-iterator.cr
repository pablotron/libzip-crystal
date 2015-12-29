module Zip
  class ArchiveIterator
    include Iterator(String)

    protected def initialize(
      @zip        : Archive, 
      @flags = 0  : Int32
    )
      @max = @zip.num_entries(@flags)
      @pos = 0_u64
    end

    def next
      if @pos < @max
        # get result
        r = @zip.get_name(@pos, @flags)

        # increment position
        @pos += 1

        # return restul
        r
      else
        # stop iterator
        stop
      end
    end

    def rewind
      @pos = 0
    end
  end
end
