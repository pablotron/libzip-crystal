module Zip
  module Flags
    @[Flags]
    # Flags for `Zip::Archive.new`, `Zip::Archive.open`, and
    # `Zip::Archive.create`.
    enum Open
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
    enum FL
      ENC_GUESS   = 0    #  guess string encoding (is default) 
      NOCASE      = 1    #  ignore case on name lookup 
      NODIR       = 2    #  ignore directory component 
      COMPRESSED  = 4    #  read compressed data 
      UNCHANGED   = 8    #  use original data, ignoring changes 
      RECOMPRESS  = 16   #  force recompression of data 
      ENCRYPTED   = 32   #  read encrypted data (implies ZIP_FL_COMPRESSED) 
      ENC_RAW     = 64   #  get unmodified string 
      ENC_STRICT  = 128  #  follow specification strictly 
      LOCAL       = 256  #  in local header 
      CENTRAL     = 512  #  in central directory 
      ENC_UTF_8   = 2048 #  string is UTF-8 encoded 
      ENC_CP437   = 4096 #  string is CP437 encoded 
      OVERWRITE   = 8192 #  zip_file_add: if file with name exists, overwrite (replace) it 
    end

    # archive global flags flags
    enum AFL
      TORRENT = 1 #  torrent zipped 
      RDONLY =  2 #  read only -- cannot be cleared 
    end

    # extra field flags
    enum ExtraField
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
      DEFAULT = -1          #  better of deflate or store
      STORE = 0             #  stored (uncompressed) 
      SHRINK = 1            #  shrunk 
      REDUCE_1 = 2          #  reduced with factor 1 
      REDUCE_2 = 3          #  reduced with factor 2 
      REDUCE_3 = 4          #  reduced with factor 3 
      REDUCE_4 = 5          #  reduced with factor 4 
      IMPLODE = 6           #  imploded 
      # 7 - Reserved for Tokenizing compression algorithm
      DEFLATE = 8           #  deflated 
      DEFLATE64 = 9         #  deflate64 
      PKWARE_IMPLODE = 10   #  PKWARE imploding 
      # 11 - Reserved by PKWARE
      BZIP2 = 12            #  compressed using BZIP2 algorithm 
      # 13 - Reserved by PKWARE
      LZMA = 14             #  LZMA (EFS) 
      # 15-17 - Reserved by PKWARE
      TERSE = 18            #  compressed using IBM TERSE (new) 
      LZ77 = 19             # IBM LZ77 z Architecture (PFS) 
      WAVPACK = 97          #  WavPack compressed data 
      PPMD = 98             #  PPMd version I, Rev 1 
    end

    @[Flags]
    enum EncryptionMethod
      NONE = 0            # not encrypted
      TRAD_PKWARE = 1     # traditional PKWARE encryption
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
      UNKNOWN = 0xffff    # unknown algorithm
    end

    @[Flags]
    enum OpSys
      DOS = 0x00
      AMIGA = 0x01
      OPENVMS = 0x02
      UNIX = 0x03
      VM_CMS = 0x04
      ATARI_ST = 0x05
      OS_2 = 0x06
      MACINTOSH = 0x07
      Z_SYSTEM = 0x08
      CPM = 0x09
      WINDOWS_NTFS = 0x0a
      MVS = 0x0b
      VSE = 0x0c
      ACORN_RISC = 0x0d
      VFAT = 0x0e
      ALTERNATE_MVS = 0x0f
      BEOS = 0x10
      TANDEM = 0x11
      OS_400 = 0x12
      OS_X = 0x13

      DEFAULT = 0x03 # UNIX
    end

    enum SourceCommand
      OPEN    # prepare for reading
      READ    # read data
      CLOSE   # reading is done
      STAT    # get meta information
      ERROR   # get error information
      FREE    # cleanup and free resources
    end

    enum SourceError
      LOWER = -2
    end

    @[Flags]
    enum Stat
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
end
