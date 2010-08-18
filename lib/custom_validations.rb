class MissingRelationError < StandardError; end

module CustomValidations
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
 
    def validates_email(*attr_names)
      configuration = attr_names.extract_options!
      attr_names = :email if attr_names.empty?
      validates_presence_of(attr_names)
      validates_length_of(attr_names, :within => 6..100)
      validates_format_of(attr_names, 
        :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,4})\Z/i,
        :message => "Please enter an email address like me@example.com")
        
      if configuration[:encrypted] 
        attr_names = ("encrypted_" + attr_names.to_s).to_sym
      end
      validates_uniqueness_of(attr_names, :case_sensitive => false) \
        if configuration[:unique]
    end

    
  end
end

class ActiveRecord::Base
  include CustomValidations
end
