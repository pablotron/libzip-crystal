module Zip
  #
  # Bindings for native libzip calls
  #
  @[Link("zip")]
  lib LibZip
    type ZipArchive = UInt8*
    type ZipFile    = UInt8*
    type ZipSource  = UInt8*
    alias ZipError  = Int32

    struct Stat
      # which fields have valid values
      valid:        UInt64

      # name of the file
      name:         UInt8*

      # index within archive
      index:        UInt64

      # size of file (uncompressed)
      size:         UInt64

      # size of file (compressed)
      comp_size:    UInt64

      # modification time
      mtime:        LibC::TimeT

      # crc of file data
      crc:          UInt32

      # compression method used
      comp_method:  UInt16

      # encryption method used
      enc_method:   UInt16

      # reserved for future use
      flags:        UInt32
    end

    #
    # The zip archive specified by *path* is opened and a pointer to a
    # zip, used to manipulate the archive, is returned.  The *flags* are
    # specified by or'ing any combination (or none) of Zip::Flags::Open,
    # or 0 for none of them.
    #
    # If an error occurs then zip_open returns NULL.  If *errorp* is not
    # nil, it will be set to the corresponding error code.
    #
    fun zip_open(
      path:         UInt8*,
      flags:        UInt32,
      errorp:       ZipError*
    ): ZipArchive

    fun zip_fdopen(
      fd:           Int32,
      flags:        UInt32,
      errorp:       ZipError*
    ): ZipArchive

    # find files
    fun zip_name_locate(
      zip:          ZipArchive,
      path:         UInt8*,
      flags:        UInt32
    ): Int64

    # open files
    fun zip_fopen(
      zip:          ZipArchive,
      path:         UInt8*,
      flags:        UInt32
    ): ZipFile

    fun zip_fopen_encrypted(
      zip:          ZipArchive,
      path:         UInt8*,
      flags:        UInt32,
      password:     UInt8*
    ): ZipFile

    fun zip_fopen_index(
      zip:          ZipArchive,
      index:        UInt64,
      flags:        UInt32
    ): ZipFile

    fun zip_fopen_index_encrypted(
      zip:          ZipArchive,
      index:        UInt64,
      flags:        UInt32,
      password:     UInt8*
    ): ZipFile

    # read files
    fun zip_fread(
      file:         ZipFile ,
      buf:          UInt8*,
      nbytes:       UInt64
    ): ZipError

    # close files
    fun zip_fclose(
      file:         ZipFile
    ): LibC::Int

    # close archive
    fun zip_close(
      zip:          ZipArchive
    ): ZipError

    fun zip_discard(
      zip:          ZipArchive
    ): Void

    # stat
    fun zip_stat(
      zip:          ZipArchive,
      path:         UInt8*,
      flags:        UInt32,
      stats:        Stat*
    ): ZipError

    fun zip_stat_index(
      zip:          ZipArchive,
      index:        LibC::Int,
      flags:        UInt32,
      stats:        Stat*
    ): ZipError

    # comments
    fun zip_file_get_comment(
      zip:          ZipArchive,
      index:        LibC::Int,
      lenp:         UInt32*,
      flags:        UInt32
    ): UInt8*

    fun zip_file_set_comment(
      zip:          ZipArchive,
      index:        LibC::Int,
      comment:      UInt8*,
      len:          UInt16,
      flags:        UInt32
    ): LibC::Int

    fun zip_get_archive_comment(
      zip:          ZipArchive,
      lenp:         UInt32*,
      flags:        UInt32
    ): UInt8*

    # archive flag
    fun zip_get_archive_flag(
      zip:          ZipArchive,
      flag:         UInt32,
      flags:        UInt32
    ): LibC::Int

    fun zip_set_archive_flag(
      zip:          ZipArchive,
      flag:         UInt32,
      value:        LibC::Int
    ): LibC::Int

    # misc
    fun zip_get_name(
      zip:          ZipArchive,
      index:        UInt64,
      flags:        UInt32
    ): UInt8*

    fun zip_get_num_entries(
      zip:          ZipArchive,
      flags:        UInt32
    ): Int64

    fun zip_set_default_password(
      zip:          ZipArchive,
      password:     UInt8*
    ): LibC::Int

    # add/replace
    fun zip_dir_add(
      zip:          ZipArchive,
      path:         UInt8*,
      flags:        UInt32
    ): UInt64

    fun zip_file_add(
      zip:          ZipArchive,
      path:         UInt8*,
      source:       ZipSource,
      flags:        UInt32
    ): UInt64

    fun zip_file_replace(
      zip:          ZipArchive,
      index:        UInt64,
      source:       ZipSource,
      flags:        UInt32
    ): UInt64

    fun zip_file_rename(
      zip:          ZipArchive,
      index:        UInt64,
      new_name:     UInt8*,
      flags:        UInt32
    ): LibC::Int

    # compression method
    fun zip_set_file_compression(
      zip:          ZipArchive,
      index:        UInt64,
      comp:         UInt32,
      flags:        UInt32
    ): LibC::Int

    # source
    fun zip_source_buffer(
      zip:          ZipArchive,
      data:         UInt8*,
      len:          UInt64,
      flags:        UInt32
    ): ZipSource

    fun zip_source_file(
      zip:          ZipArchive,
      path:         UInt8*,
      start:        UInt64,
      len:          UInt64
    ): ZipSource

    fun zip_source_filep(
      zip:          ZipArchive,
      fh:           Void*,
      start:        UInt64,
      len:          UInt64
    ): ZipSource

    fun zip_source_function(
      zip:          ZipArchive,
      cb:           (Void*, UInt8*, UInt64, Int32) -> Int64,
      data:         Void*
    ): ZipSource

    fun zip_source_zip(
      zip:          ZipArchive,
      src_zip:      ZipArchive,
      src_index:    UInt64,
      flags:        UInt32,
      start:        UInt64,
      len:          Int64
    ): ZipSource

    # delete
    fun zip_delete(
      zip:          ZipArchive,
      index:        UInt64
    ): LibC::Int

    # unchange
    fun zip_unchange(
      zip:          ZipArchive,
      index:        UInt64
    ): LibC::Int

    fun zip_unchange_all(
      zip:          ZipArchive,
      index:        UInt64
    ): LibC::Int

    fun zip_unchange_archive(
      zip:          ZipArchive,
      index:        UInt64
    ): LibC::Int

    # extra field methods
    fun zip_file_extra_field_get(
      zip:          ZipArchive,
      index:        UInt64,
      field_index:  UInt16,
      indexp:       UInt16*,
      lenp:         UInt16*,
      flags:        UInt32
    ): UInt8*

    fun zip_file_extra_field_get_by_id(
      zip:          ZipArchive,
      field_id:     UInt16,
      field_index:  UInt16,
      lenp:         UInt16*,
      flags:        UInt32
    ): UInt8*

    fun zip_file_extra_field_set(
      zip:          ZipArchive,
      index:        UInt64,
      field_id:     UInt16,
      field_index:  UInt16,
      data:         UInt8*,
      len:          UInt16,
      flags:        UInt32
    ): LibC::Int

    fun zip_file_extra_fields_count(
      zip:          ZipArchive,
      index:        UInt64,
      flags:        UInt32
    ): Int16

    fun zip_file_extra_fields_count_by_id(
      zip:          ZipArchive,
      index:        UInt64,
      field_id:     UInt16,
      flags:        UInt32
    ): Int16

    # archive comment
    fun zip_set_archive_comment(
      zip:          ZipArchive,
      comment:      UInt8*,
      len:          UInt16
    ): LibC::Int

    # error functions
    fun zip_error_to_str(
      buf:          UInt8*,
      len:          UInt64,
      ze:           ZipError,
      se:           ZipError,
    ): LibC::Int

    fun zip_file_strerror(
      zip_file:     ZipFile
    ): UInt8*

    fun zip_strerror(
      zip:          ZipArchive
    ): UInt8*

    fun zip_error_get(
      zip:          ZipArchive,
      zep:          ZipError*,
      sep:          ZipError*
    ): Void

    fun zip_error_clear(
      zip:          ZipArchive
    ): Void

    fun zip_file_error_get(
      zip_file:     ZipFile,
      zep:          ZipError*,
      sep:          ZipError*
    ): Void

    fun zip_error_get_sys_type(
      ze:           ZipError
    ): ErrorType
  end
end
