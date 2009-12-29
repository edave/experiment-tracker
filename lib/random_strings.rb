class String
  def self.random(length=12)
    # Return a random string of approximately this length
    [Array.new(length){rand(256).chr}.join].pack("m")[0...-2]
  end

  def self.random_hash(*args)
    # Return a random string based on hashing these (optional) arguments
    # with a random seed value
    values_to_hash = [self.random] + args
    Digest::SHA256.hexdigest("--#{values_to_hash.join('--')}--")
  end
end
