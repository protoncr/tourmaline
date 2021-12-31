struct Slice(T)
  def to_bytes
    Bytes.new(self.to_unsafe.as(Pointer(UInt8)), self.bytesize)
  end
end
