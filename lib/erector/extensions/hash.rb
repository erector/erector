class Hash
  module CorrectlyHashedHash
    def hash
      out = 0
      # This sort_by is all kinds of weird...basically, we need a deterministic order here,
      # but we can't just use "sort", because keys aren't necessarily sortable (they don't
      # necessarily respond to <=>). Sorting by their hash codes works just as well, and
      # is guaranteed to work, since everything hashes.
      keys.sort_by { |k| k.hash }.each { |k| out ^= k.hash; out ^= self[k].hash }
      out
    end

    def eql?(o)
      self == o
    end
  end
  
  def correctly_hashed
    extend(CorrectlyHashedHash)
  end
end