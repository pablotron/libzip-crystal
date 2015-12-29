require "../spec_helper"

SOURCE_FILES = Dir.glob("src/zip/**.cr")

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
        zip.stat(path).size.should eq File.stat(path).size
      end
    end
  end
end
