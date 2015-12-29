require "../spec_helper"

class TestProcSource < Zip::ProcSource
  property pos
  property data

  def initialize(zip, data)
    # reset position and cache data slice
    @pos = 0
    @data = data.to_slice

    super(zip, ->(
      action    : Zip::Action,
      slice     : Slice(UInt8),
      user_data : Void* \
    ) {
      # cast data pointer back to "self"
      me = user_data as TestProcSource

      # switch on action, then coerce result to i64
      0_i64 + case action
      when .open?
        # reset position
        me.pos = 0

        # return 0
        0
      when .read?
        if me.pos < data.bytesize
          # get shortest length
          len = me.data.bytesize - me.pos
          len = slice.bytesize if slice.bytesize < len

          if len > 0
            # copy string data to slice and increment position
            slice.copy_from(me.data[me.pos, len].to_unsafe, len)
            me.pos += len
          end

          # return length
          len
        else
          # puts "read: done"
          0
        end
      when .stat?
        # get size of stat struct
        st_size = sizeof(Zip::LibZip::Stat)

        # create and populate stat struct
        st = Zip::LibZip::Stat.new(
          valid:  Zip::StatFlag::SIZE.value,
          size:   me.data.bytesize
        )

        # copy populated struct to slice
        slice.copy_from(pointerof(st) as Pointer(UInt8), st_size)

        # return sizeof stat
        st_size
      else
        # for all other actions, do nothing
        0
      end
    }, self as Pointer(Void))
  end
end

describe "Zip::ProcSource" do
  it "can read files from a custom source" do
    # remove test zip
    File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

    # populate zip with test file
    Zip::Archive.create(ZIP_PATH) do |zip|
      # add "text.txt" from custom Zip::ProcSource
      zip.add("test.txt", TestProcSource.new(zip, TEST_STRING))
    end

    # open zip file for reading
    Zip::Archive.open(ZIP_PATH) do |zip|
      # read "test.txt", then compare it to TEST_STRING
      String.build do |b|
        zip.read("test.txt") do |buf, len|
          b.write(buf[0, len])
        end
      end.should eq TEST_STRING
    end
  end
end
