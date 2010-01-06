class Appointment < ActiveRecord::Base
  belongs_to :slot, :counter_cache => true
  belongs_to :subject, :counter_cache => true
end
