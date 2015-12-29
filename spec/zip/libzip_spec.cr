require "../spec_helper"

describe "Zip::LibZip" do
  it "links properly to libzip" do
    zip = Zip::LibZip.zip_open("test.zip", 0, nil)
    Zip::LibZip.zip_discard(zip)
  end
end
