require 'zlib'

module BioBgzf
    # Unpacks compressed data, NOT a BGZF block.
    def unpack(str)
        zs = Zlib::Inflate.new(-15)
        zs.inflate(str)
    end
    extend self
end
