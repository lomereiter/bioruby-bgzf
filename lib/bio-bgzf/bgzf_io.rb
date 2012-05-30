class IO
  # Yields compressed block, expected size of uncompressed data,
  #    and expected CRC32 of uncompressed data.
  def each_bgzf
    while not eof? do
      magic, gzip_extra_length = read(12).unpack('Vxxxxxxv')
      raise 'wrong BGZF magic' unless magic == 0x04088B1F

      len = 0
      bsize = nil
      while len < gzip_extra_length do
        si1, si2, slen = read(4).unpack('CCv')
        if si1 == 66 and si2 == 67 then
          raise "BC subfield length is #{slen} but must be 2" if slen != 2
          raise 'duplicate field with block size' unless bsize.nil?
          bsize = read(2).unpack('v')[0]
          seek(slen - 2, IO::SEEK_CUR)
        else
          seek(slen, IO::SEEK_CUR)
        end
        len += 4 + slen
      end

      if len != gzip_extra_length then
        raise "total length of subfields is #{len} bytes but must be #{gzip_extra_length}"
      end
      raise 'block size was not found in any subfield' if bsize.nil?

      compressed_data = read(bsize - gzip_extra_length - 19)
      crc32, input_size = read(8).unpack('VV')

      yield compressed_data, input_size, crc32
    end
  end
end
