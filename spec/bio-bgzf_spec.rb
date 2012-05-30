require 'rspec/expectations'
require 'bio-bgzf'
require 'tempfile'

describe "BioBgzf" do
  it "should be able to pack strings to BGZF blocks" do
    BioBgzf.should respond_to(:pack).with(1).argument
    BioBgzf.pack("asdfghjkl").should be_instance_of String
  end

  it "should be able to iteratively read BGZF blocks from stream" do
    str = ''
    1000.times { str += (Random.rand(26) + 65).chr }

    file = Tempfile.new 'bgzfstring'
    str.chars.each_slice(42).map(&:join).each do |s|
        file.write(BioBgzf.pack s)
    end
    file.flush
    file.rewind

    str2 = ''
    file.each_bgzf {|block| str2 += BioBgzf.unpack(block) }

    str2.should == str
  end
end
