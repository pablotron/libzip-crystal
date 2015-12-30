require "./zip/*"

# Crystal bindings for [libzip](http://www.nih.at/libzip/), which allows
# you to create and modify Zip archives.  Below are a couple of simple
# examples.  See `Zip::Archive` for additional documentation.
#
# ### Examples
#
#     # create a new archive named foo.zip and populate it
#     Zip::Archive.create("foo.zip") do |zip|
#       # add file "/path/to/foo.png" to archive as "bar.png"
#       zip.add_file("bar.png", "/path/to/foo.png")
#
#       # add file "baz.txt" with contents "hello world!"
#       zip.add("baz.txt", "hello world!")
#     end
#
#     # read "bar.txt" as string from "foo.zip"
#     Zip::Archive.open("foo.zip") do |zip|
#       # read contents of "bar.txt" as string
#       str = String.new(zip.read("bar.txt"))
#
#       # print contents of bar.txt
#       puts "contents of bar.txt: #{str}"
#     end
#
module Zip
end
