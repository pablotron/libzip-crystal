module Zip
  class ArchiveIterator
    include Iterator(String)

    def initialize(@zip : Archive, flags = 0 : Int32)
      @max = @zip.get_num_entries(flags)
      @pos = 0
    end

    def next
      if @pos < @max
        r = @zip.get_name(@pos, flags)
        @pos += 1
      else
        stop
      end
    end

    def rewind
      @pos = 0
    end
  end
end
