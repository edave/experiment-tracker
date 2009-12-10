
# Obfuscate ids
HASHED_PRIME = 2971215073
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

    def belongs_to(association_id, options={})
      # Augment belongs_to to also declare hashed getters and setters
      super
      klass_name = (options[:class_name] || association_id).to_s
      klass = klass_name.classify.constantize
      if klass.instance_methods.include? "save_hashed_id"
        define_method("#{association_id}_hashed_id".to_sym) do
          raw_id = send("#{association_id}_id")
          raw_id && raw_id.to_hashed_id
        end
        define_method("#{association_id}_hashed_id=".to_sym) do |hashed_id|
          clean_value = !hashed_id.blank? && \
            (klass.clean_find(hashed_id).first || raise(ActiveRecord::RecordNotFound))
          send("#{association_id}_id=", clean_value.id) if clean_value
        end
      end
    end
  end

  module InstanceMethods
    def save_hashed_id
      # skip validations since we just want to save this hashed id
      # Relies on our extension to ActiveRecord to just update the 
      # hashed_id attribute
      self.update_single_attribute(:hashed_id, self.id.to_hashed_id)
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
