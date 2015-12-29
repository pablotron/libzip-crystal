require "../spec_helper"

# build destination zip path
DST_PATH = File.join(
  File.dirname(ZIP_PATH),
  "dst-" + File.basename(ZIP_PATH)
)

describe "Zip::ArchiveSource" do
  it "can read files from another archive" do
    # remove test zips
    [ZIP_PATH, DST_PATH].each do |path|
      File.delete(path) if File.exists?(path)
    end

    # populate src zip with test files
    Zip::Archive.create(ZIP_PATH) do |zip|
      TEST_FILES.each do |path|
        zip.add(path, path)
      end
    end

    # open src zip file for reading
    Zip::Archive.open(ZIP_PATH) do |src_zip|
      # open dst zip file for writing
      Zip::Archive.create(DST_PATH) do |dst_zip|
        TEST_FILES.each do |path|
          # create source
          source = Zip::ArchiveSource.new(dst_zip, src_zip, path)

          # add source to destination zip file
          dst_zip.add(path, source)
        end
      end
    end

    # check files in dst archive
    Zip::Archive.open(DST_PATH) do |zip|
      TEST_FILES.each do |path|
        # read file contents
        str = String.build do |b|
          zip.read(path) do |buf, len|
            b.write(buf[0, len])
          end
        end

        # test file contents
        str.should eq path
      end
    end
  end
end
