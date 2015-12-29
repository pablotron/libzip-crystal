require "./zip/*"

# Crystal bindings for [libzip](http://www.nih.at/libzip/), which allows
# you to create and modify Zip archives.  Below are a couple of simple
# examples.  See `Zip::Archive` for additional documentation.
#
# ### Examples
#
#     # create a new archive named foo.zip and populate it
#     Zip::Archive.create("foo.zip") do |zip|
#       # add file "/path/to/foo.txt" to archive as "bar.txt"
#       zip.add_file("bar.txt", "/path/to/foo.txt")
#
#       # add file "baz.txt" with contents "hello world!"
#       zip.add("baz.txt", "hello world!")
#     end
#
#     # open existing archive "foo.zip" and extract "bar.txt" from it
#     Zip::Archive.open("foo.zip") do |zip|
#       # build string
#       str = String.build do |b|
#         # read file in chunks
#         zip.read("bar.txt") do |buf, len|
#           b.write(buf[0, len])
#         end
#       end
#
#       # print contents of bar.txt
#       puts "contents of bar.txt: #{str}"
#     end
#
module Zip
end
