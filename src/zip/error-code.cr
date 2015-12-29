module Zip
  # LibZip error codes.
  enum ErrorCode
    #  N No error
    OK = 0

    #  N Multi-disk zip archives not supported
    MULTIDISK = 1

    #  S Renaming temporary file failed
    RENAME = 2

    #  S Closing zip archive failed
    CLOSE = 3

    #  S Seek error
    SEEK = 4

    #  S Read error
    READ = 5

    #  S Write error
    WRITE = 6

    #  N CRC error
    CRC = 7

    #  N Containing zip archive was closed
    ZIPCLOSED = 8

    #  N No such file
    NOENT = 9

    #  N File already exists
    EXISTS = 10

    #  S Can't open file
    OPEN = 11

    #  S Failure to create temporary file
    TMPOPEN = 12

    #  Z Zlib error
    ZLIB = 13

    #  N Malloc failure
    MEMORY = 14

    #  N Entry has been changed
    CHANGED = 15

    #  N Compression method not supported
    COMPNOTSUPP = 16

    #  N Premature EOF
    EOF = 17

    #  N Invalid argument
    INVAL = 18

    #  N Not a zip archive
    NOZIP = 19

    #  N Internal error
    INTERNAL = 20

    #  N Zip archive inconsistent
    INCONS = 21

    #  S Can't remove file
    REMOVE = 22

    #  N Entry has been deleted
    DELETED = 23

    #  N Encryption method not supported
    ENCRNOTSUPP = 24

    #  N Read-only archive
    RDONLY = 25

    #  N No password provided
    NOPASSWD = 26

    #  N Wrong password provided
    WRONGPASSWD = 27

    def message
      buf = Slice(UInt8).new(1024)
      len = LibZip.zip_error_to_str(buf, buf.size, self.value, 0)
      String.new(buf[0, len])
    end
  end
end
