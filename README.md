# libzip-crystal

Crystal bindings for libzip.

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

# create zip file named "foo.zip" with a file "bar.txt" containng the
# string "hello world!"
Zip::Archive.create("foo.zip") do |zip|
  zip.add("bar.txt", "hello world!")
end

# read contents of "bar.txt" inside "foo.zip"
str = Zip::Archive.open("foo.zip") do |zip|
  # create slice buffer
  buf = Slice(UInt8).new(1024)

  # create string builder
  String.build do |b|
    # open "bar.txt"
    zip.open("bar.txt") do |fh|
      # read slices from file
      while ((len = fh.read(buf)) > 0)
        b.write(buf[0, len])
      end
    end
  end
end

```


TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/pablotron/libzip-crystal/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [pabs](https://github.com/pablotron) Paul Duncan - creator, maintainer
