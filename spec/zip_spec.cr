require "./spec_helper"

ZIP_PATH = "spec/out/test.zip"
BAD_PATH = "/dev/null/bad.zip"
TEST_FILES = %w{foo.txt bar.png baz.jpeg blum.html}
TEST_STRING = "This is a test string."

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
      user_data : Void*) {
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

describe "Zip" do
  describe "LibZip" do
    it "links properly to libzip" do
      zip = Zip::LibZip.zip_open("test.zip", 0, nil)
      Zip::LibZip.zip_discard(zip)
    end
  end

  describe "Archive" do
    it "can create a new archive imperatively" do
      # remove test zip
      File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

      # create archive, then close it
      zip = Zip::Archive.create(ZIP_PATH).close
    end

    it "can create a new archive with a block" do
      # remove test zip
      File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

      Zip::Archive.create(ZIP_PATH) do |zip|
        zip.add("foo.txt", "bar")
      end

      # return success
      true
    end

    it "can throw an error message when creating a new archive" do
      expect_raises(Zip::Error) do
        Zip::Archive.create(BAD_PATH) do |zip|
          zip.add("foo", "bar")
        end
      end
    end

    it "can get the last archive error" do
      # remove test zip
      File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

      Zip::Archive.create(ZIP_PATH) do |zip|
        zip.error
      end
    end

    it "can add a file from a string" do
      # remove test zip
      File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

      # create archive
      Zip::Archive.create(ZIP_PATH) do |zip|
        zip.add("foo.txt", "bar")
      end
    end

    it "can set an archive comment" do
      # remove test zip
      File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

      Zip::Archive.create(ZIP_PATH) do |zip|
        # set comment
        zip.comment = "foo"

        # add at least one file
        zip.add("foo.txt", "bar")
      end

      Zip::Archive.open(ZIP_PATH) do |zip|
        zip.comment.should eq "foo"
      end

      # return success
      true
    end

    it "can find a file by name" do
      # remove test zip
      File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

      Zip::Archive.create(ZIP_PATH) do |zip|
        # add at least one file
        zip.add("foo.txt", "bar")
      end

      Zip::Archive.open(ZIP_PATH) do |zip|
        zip.name_locate("foo.txt").should eq 0
      end
    end

    it "can read a file from an archive" do
      # remove test zip
      File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

      # populate zip with test files
      Zip::Archive.create(ZIP_PATH) do |zip|
        TEST_FILES.each do |file|
          zip.add(file, file)
        end
      end

      # read test files from zip
      Zip::Archive.open(ZIP_PATH) do |zip|
        # create buffer
        buf = Slice(UInt8).new(1024)

        TEST_FILES.each do |path|
          zip.open(path) do |fh|
            String.build do |b|
              while ((len = fh.read(buf)) > 0)
                b.write(buf[0, len])
              end
            end.should eq path
          end
        end
      end
    end

    it "can stat files from an archive" do
      # remove test zip
      File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

      # populate zip with test files
      Zip::Archive.create(ZIP_PATH) do |zip|
        TEST_FILES.each do |file|
          zip.add(file, file)
        end
      end

      # read test files from zip
      Zip::Archive.open(ZIP_PATH) do |zip|
        # create buffer
        buf = Slice(UInt8).new(1024)

        TEST_FILES.each do |path|
          st = zip.stat(path)
          zip.stat(path).size.should eq path.bytesize
        end
      end
    end

    it "can read files from a custom source" do
      # remove test zip
      File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

      # populate zip with test files
      Zip::Archive.create(ZIP_PATH) do |zip|
        # add "text.txt" from custom Zip::ProcSource
        zip.add("test.txt", TestProcSource.new(zip, TEST_STRING))
      end

      # open zip file for reading
      Zip::Archive.open(ZIP_PATH) do |zip|
        # create buffer
        size = zip.stat("test.txt").size
        buf = Slice(UInt8).new(1024)

        # read "test.txt" into string buffer, then compare buffer to
        # TEST_STRING
        zip.open("test.txt") do |fh|
          String.build do |b|
            while ((len = fh.read(buf)) > 0)
              b.write(buf[0, len])
            end
          end
        end.should eq TEST_STRING
      end
    end
  end
end
