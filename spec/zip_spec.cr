require "./spec_helper"

ZIP_PATH = "spec/out/test.zip"
BAD_PATH = "/dev/null/bad.zip"
TEST_FILES = %w{foo.txt bar.png baz.jpeg blum.html}

class TestCustomSource
  DATA = "This is a test string."

  def initialize(zip)
    @data = DATA.to_slice
    @pos = 0

    super(zip, ->(
      user_data     : Void*, 
      data          : UInt8*, 
      len           : UInt64, 
      action_value  : Int32) do
      source = user_data as TestCustomSource
      action = Zip::SourceAction.new(action_value)

      if action.open?
        source.source_open
      elsif action.read?
        source.source_read(Slice.new(data, len))
      else
        0
      end
    end, Pointer(Void).new(self.object_id))
  end

  def source_open
    @pos = 0
  end

  def source_read(slice : Slice(UInt8))
    puts "in TestCustomSource#source_read"
    if @pos < @data.bytesize
      # get shortest length
      len = @data.bytesize - @pos
      len = slice.bytesize if slice.bytesize < len

      # get data pointer
      ptr = Pointer(UInt8).new(@data.to_unsafe.address) + @pos

      slice.copy_from(ptr, len)
      @pos += len

      # return length
      len
    else
      0
    end
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
        TEST_FILES.each do |file| 
          zip.add(file, file)
        end

        zip.add("test.txt", TestCustomSource.new(zip))
      end
    end
  end
end
