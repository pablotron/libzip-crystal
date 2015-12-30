# libzip-crystal

Crystal bindings for [libzip](http://www.nih.at/libzip/), which allows
you to create and modify Zip archives.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  libzip-crystal:
    github: pablotron/libzip-crystal
```

## Usage

```crystal
require "zip"

# create a new archive named foo.zip and populate it
Zip::Archive.create("foo.zip") do |zip|
  # add file "/path/to/foo.png" to archive as "bar.png"
  zip.add_file("bar.png", "/path/to/foo.png")

  # add file "baz.txt" with contents "hello world!"
  zip.add("baz.txt", "hello world!")
end

# read baz.txt from archive foo.zip
Zip::Archive.open("foo.zip") do |zip|
  # read bzr.txt as string
  str = String.new(zip.read("baz.txt"))

  # print baz.txt
  puts "contents of baz.txt: #{str}"
end
```

## Contributing

1. Fork it ( https://github.com/pablotron/libzip-crystal/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [pabs](https://github.com/pablotron) Paul Duncan - creator, maintainer
