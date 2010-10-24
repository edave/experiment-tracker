
# Obfuscate ids
HASHED_PRIME = 321060967
HASHED_MAXID = 2**31-1

class Fixnum
  def to_hashed_id
    self * HASHED_PRIME & HASHED_MAXID
  end
end

module HashedId
  
  def self.included(base)
    base.extend ActsAs
  end

  module ActsAs
    # Add ID-hashing behavior to this model
    # - it requires a hashed_id column in the database
    # - after the first save, its id will be hashed and saved
    def has_hashed_id(options={})
      self.send(:include, HashedId::InstanceMethods)
      after_create :save_hashed_id
    end
  end

  module InstanceMethods
    def save_hashed_id
      # skip validations since we just want to save this hashed id
      # Relies on our extension to ActiveRecord to just update the 
      # hashed_id attribute
      self.update_attribute(:hashed_id, self.id.to_hashed_id)
    end

    def to_param
      (self.hashed_id || self.id.to_hashed_id).to_s
    end
    
    def humanized_id
      return self.hashed_id.to_s(16) if self.hashed_id
      "---"
    end
  end
end

class ActiveRecord::Base
  include HashedId
end
