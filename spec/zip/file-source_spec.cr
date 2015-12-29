require "../spec_helper"

describe "Zip::FileSource" do
  it "can read files from disk" do
    File.delete(ZIP_PATH) if File.exists?(ZIP_PATH)

    # populate src zip with test files
    Zip::Archive.create(ZIP_PATH) do |zip|
      SOURCE_FILES.each do |path|
        zip.add_file(path)
      end
    end

    # open src zip file for reading
    Zip::Archive.open(ZIP_PATH) do |zip|
      SOURCE_FILES.each do |path|
        String.build do |b|
          zip.read(path) do |buf, len|
            b.write(buf[0, len])
          end
        end.should eq File.read(path)
      end
    end
  end
end
