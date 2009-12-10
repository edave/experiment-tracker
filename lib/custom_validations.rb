class MissingRelationError < StandardError; end

module CustomValidations
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    
    def validates_date_range(starts_at_attr, ends_at_attr, options={})
      def valid_date?(d)
        (300.years.ago .. 300.years.from_now).include? d
      end
      validates_each starts_at_attr do |record, attr, value|
        record.errors.add(attr, "must be a valid date") \
          unless valid_date?(value)
      end
      validates_each ends_at_attr do |record, attr, value|
        if value.blank?
          record.errors.add(attr, "must be a valid date")\
            unless options[:open_end]
        elsif !valid_date?(value)
          record.errors.add(attr, "must be a valid date")
        elsif record.starts_at and value <= record.starts_at
          record.errors.add(attr,
            "must be after #{starts_at_attr.to_s.humanize}")
        end
      end
    end

    def validates_email(*attr_names)
      configuration = attr_names.extract_options!
      attr_names = :email if attr_names.empty?
      validates_presence_of(attr_names)
      validates_length_of(attr_names, :within => 6..100)
      validates_format_of(attr_names, 
        :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,4})\Z/i,
        :message => "Please enter an email address like me@example.com")
      validates_uniqueness_of(attr_names, :case_sensitive => false) \
        if configuration[:unique]
    end

    def validates_percentage(*attr_names)
      options = attr_names.extract_options!
      options[:only_integer] ||= true
      min = options[:greater_than_or_equal_to] ||= 0
      max = (options[:less_than_or_equal_to] ||= 100)
      options[:message] ||= "must be a percentage (0 to 100)"
      validates_numericality_of(attr_names, options) 
    end

    def validates_day_range(*attr_names)
      options = attr_names.extract_options!
      options[:only_integer] ||= true
      min = options[:greater_than_or_equal_to] ||= 0
      max = (options[:less_than_or_equal_to] ||= 31)
      options[:message] ||= "must be a number of days between #{min} and #{max}"
      validates_numericality_of(attr_names, options) 
    end
    
    def validates_nonzero(attr_names)
      validates_each attr_names do |record, attr_name, value|
        record.errors.add(attr_name, "must not be zero") if value == 0
      end
    end

    
  end
end

class ActiveRecord::Base
  include CustomValidations
end
