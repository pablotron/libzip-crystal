module Zip
  @[Flags]
  # Flags for `Zip::Archive.new`, `Zip::Archive.open`, and
  # `Zip::Archive.create`.
  enum OpenFlag
    # Create archive if it does not exist.
    CREATE         = 1

    # Raise error if archive already exists.
    EXCL           = 2

    # Perform additional stricter consistency checks on the archive,
    # and error if they fail.
    CHECKCONS      = 4

    # If archive exists, ignore its current conents.  In other words,
    # handle it in the same way as an empty archive.
    TRUNCATE       = 8
  end

  @[Flags]
  # zip_name_locate, zip_fopen, zip_stat, etc flags
  enum FileFlag
    #  guess string encoding (default)
    ENC_GUESS   = 0

    #  ignore case on name lookup
    NOCASE      = 1

    #  ignore directory component
    NODIR       = 2

    #  read compressed data
    COMPRESSED  = 4

    #  use original data, ignoring changes
    UNCHANGED   = 8

    #  force recompression of data
    RECOMPRESS  = 16

    #  read encrypted data (implies ZIP_FL_COMPRESSED)
    ENCRYPTED   = 32

    #  get unmodified string
    ENC_RAW     = 64

    #  follow specification strictly
    ENC_STRICT  = 128

    #  in local header
    LOCAL       = 256

    #  in central directory
    CENTRAL     = 512

    #  string is UTF-8 encoded
    ENC_UTF_8   = 2048

    #  string is CP437 encoded
    ENC_CP437   = 4096

    #  zip_file_add: if file with name exists, overwrite (replace) it
    OVERWRITE   = 8192
  end

  # archive global flags
  enum ArchiveFlag
    TORRENT = 1 #  torrent zipped
    RDONLY =  2 #  read only -- cannot be cleared
  end

  # extra fields
  enum ExtraField : UInt16
    ALL	= 65535
    NEW	= 65535
  end

  # compression and encryption source flags
  enum Codec
    DECODE = 0 # decompress/decrypt (encode flag not set)
    ENCODE = 1 # compress/encrypt
  end

  enum ErrorType
    NONE = 0  #  sys_err unused
    SYS = 1   #  sys_err is errno
    ZLIB = 2  #  sys_err is zlib error code
  end

  @[Flags]
  # compression methods
  enum CompressionMethod
    #  better of deflate or store
    DEFAULT = -1

    #  stored (uncompressed)
    STORE = 0

    #  shrunk
    SHRINK = 1

    #  reduced with factor 1
    REDUCE_1 = 2

    #  reduced with factor 2
    REDUCE_2 = 3

    #  reduced with factor 3
    REDUCE_3 = 4

    #  reduced with factor 4
    REDUCE_4 = 5

    #  imploded
    IMPLODE = 6

    # 7 - Reserved for Tokenizing compression algorithm

    #  deflated
    DEFLATE = 8

    #  deflate64
    DEFLATE64 = 9

    #  PKWARE imploding
    PKWARE_IMPLODE = 10

    # 11 - Reserved by PKWARE

    #  compressed using BZIP2 algorithm
    BZIP2 = 12

    # 13 - Reserved by PKWARE

    #  LZMA (EFS)
    LZMA = 14

    # 15-17 - Reserved by PKWARE

    #  compressed using IBM TERSE (new)
    TERSE = 18

    # IBM LZ77 z Architecture (PFS)
    LZ77 = 19

    #  WavPack compressed data
    WAVPACK = 97

    #  PPMd version I, Rev 1
    PPMD = 98
  end

  @[Flags]
  enum EncryptionMethod
    # not encrypted
    NONE = 0

    # traditional PKWARE encryption
    TRAD_PKWARE = 1

    # # Strong Encryption Header not parsed yet
    # DES = 0x6601        # strong encryption: DES
    # RC2_OLD = 0x6602    # strong encryption: RC2, version < 5.2
    # 3DES_168 = 0x6603
    # 3DES_112 = 0x6609
    # AES_128 = 0x660e
    # AES_192 = 0x660f
    # AES_256 = 0x6610
    # RC2 = 0x6702        # strong encryption: RC2, version >= 5.2
    # RC4 = 0x6801

    # unknown algorithm
    UNKNOWN = 0xffff
  end

  @[Flags]
  enum OpSys
    DOS           = 0x00
    AMIGA         = 0x01
    OPENVMS       = 0x02
    UNIX          = 0x03
    VM_CMS        = 0x04
    ATARI_ST      = 0x05
    OS_2          = 0x06
    MACINTOSH     = 0x07
    Z_SYSTEM      = 0x08
    CPM           = 0x09
    WINDOWS_NTFS  = 0x0a
    MVS           = 0x0b
    VSE           = 0x0c
    ACORN_RISC    = 0x0d
    VFAT          = 0x0e
    ALTERNATE_MVS = 0x0f
    BEOS          = 0x10
    TANDEM        = 0x11
    OS_400        = 0x12
    OS_X          = 0x13

    DEFAULT       = 0x03 # UNIX
  end

  enum SourceCommand
    # prepare for reading
    OPEN

    # read data
    READ

    # reading is done
    CLOSE

    # get meta information
    STAT

    # get error information
    ERROR

    # cleanup and free resources
    FREE
  end

  enum SourceError
    LOWER = -2
  end

  @[Flags]
  enum StatFlag
    NAME = 0x0001
    INDEX = 0x0002
    SIZE = 0x0004
    COMP_SIZE = 0x0008
    MTIME = 0x0010
    CRC = 0x0020
    COMP_METHOD = 0x0040
    ENCRYPTION_METHOD = 0x0080
    FLAGS = 0x0100
  end
end
