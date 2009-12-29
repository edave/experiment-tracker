# Mark a model as "deactivated" in the database
#
# Requires these columns:
#   t.boolean  "frozen_in_db", :default => false
#   t.datetime "deactivated_at"

module Deactivated
  def self.included(base)
    base.extend ActsAs
    base.named_scope :undeactivated, :conditions => ["frozen_in_db != ?", true]
  end

  module ActsAs
    def acts_as_deactivated
      self.send(:include, Deactivated::InstanceMethods)
      before_destroy :deactivated?
      before_update  :not_frozen_in_db?
    end
  end

  module InstanceMethods
    def not_deactived?
        return !self.deactivated
    end
    
    def deactivated?
        #puts "DEACTIVATED======================="
        #puts self.deactivated_at.nil?
        #puts self.recently_deactivated?
        return !self.deactivated_at.nil? || self.recently_deactivated?
    end
    
     # Sets a model as "deleted"
    def deactivate!
      @deactivated = true
      self.deactivated_at = Time.now.utc
      self.frozen_in_db = true
      if self.class.method_defined?(:before_deactivate)
        self.before_deactivate
      end
      self.save!
      #self.freeze()
    end
  
    def recently_deactivated?
     return (@deactivated == true) ? true : false
   end
   
   def freeze_in_db!
     self.frozen_in_db = true
     self.save
     #self.freeze()
   end
   
   def not_frozen_in_db?
    changed = self.frozen_in_db_changed?
    return (changed && self.frozen_in_db) ? true : !frozen_in_db?
   end
   
    end
end

class ActiveRecord::Base
  include Deactivated
end
