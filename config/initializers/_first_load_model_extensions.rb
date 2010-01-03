# Load our ActiveRecord extensions

# Name is a hack to get this file loaded before other initializers which may need these
# extensions to properly load models

require 'attr_encrypted'

require "#{Rails.root}/lib/hashed_id"

require "#{Rails.root}/lib/custom_validations"

require "#{Rails.root}/lib/deactivated"

require "#{Rails.root}/lib/eula"

require "#{Rails.root}/lib/random_strings"

class ActiveRecord::Base
  # Give all models access to the current manager & user, both 
  # for doing constrained lookups and for storing whodunit.
  cattr_accessor :current_user_id
end


class ::Date
  def beginning_of_day_in_zone
    Time.zone.parse(self.to_s)
  end
  alias_method :at_beginning_of_day_in_zone, :beginning_of_day_in_zone
  alias_method :midnight_in_zone, :beginning_of_day_in_zone
  alias_method :at_midnight_in_zone, :beginning_of_day_in_zone

  def end_of_day_in_zone
    Time.zone.parse((self+1).to_s) - 1
  end
end