require 'gcal4ruby'
class GoogleCalendar < ActiveRecord::Base
  has_hashed_id
  has_many :experiments
  
  attr_accessible :login, :password, :name
  
  attr_encrypted :login, :key => ENCRYPTED_ATTR_PASSKEY
  attr_encrypted :password, :key => ENCRYPTED_ATTR_PASSKEY
   
  validates_presence_of :login
  validates_presence_of :password
  validates_presence_of :name
  
  validate :confirm_login
  validate :confirm_calendar
  
  before_save :find_calendar_id
  
  def self.calendars(login, password)
    service = self.get_service()
    unless service == nil
      return GCal4Ruby::Calendar.find(service, :all)
    end
  end
  
  def find_calendar_id
    service = self.get_service()
    if service
    new_calendar = GCal4Ruby::Calendar.find(service, name, {'max-results' => '10'})
    if new_calendar == nil or new_calendar.empty?
      errors.add(:name, "Calendar could not be found")
      return false
    end
    new_calendar = new_calendar.first
    self.calendar_id = new_calendar.id
    self.name = new_calendar.title
    end
  end
  
  def calendar_html
    my_calendar = self.calendar
    html = "Error: calendar not found"
    unless my_calendar == nil
      html = my_calendar.to_iframe({:showCalendars => '0', :showTz => '0', :showTitle => '0'})
      #logger.info("Cal: #{html}")
    end
    return html
  end
  
  def confirm_login
    if self.get_service == nil
      errors.add(:login, " or password is not correct")
      return false
    end
    return true
  end
  
  def confirm_calendar
    service = self.get_service()
    if service != nil and !name.blank?
      new_calendar = GCal4Ruby::Calendar.find(service, name, {:scope => :first})
      unless new_calendar == nil || new_calendar.empty?
        return true
      end
    end
    errors.add(:name, " could not find a calendar with this name")
      
    return false
  end
  
  def calendar
    service = self.get_service()
    if service != nil
      my_calendar = GCal4Ruby::Calendar.find(service, {:id=>self.calendar_id})
      return nil if my_calendar.class == Array.class and my_calendar.empty?
      
      return my_calendar
    end
  end
  
  def add_scheduled_slot(experiment, slot, subject)
    start_time = slot.time
    endtime = start_time + experiment.time_length.minutes
    event = GCal4Ruby::Event.new(get_service, {:calendar => self.calendar})
    event.title = experiment.name + ' - ' + subject.name
    event.content = "An experiment for " + experiment.name \
                  + " was automatically scheduled for this time by the Experiment Signup Tool\n"  \
                  + "Subject: " + subject.name \
                  + "\n\nExperiment Contact " + experiment.user.name + ", " + experiment.user.email
    event.where = experiment.location.human_location
    event.start_time = start_time
    event.end_time = endtime
    event.save
  end 
  
  def get_service()
    return GoogleCalendar.get_service(self.login, self.password)
  end
  
  def self.get_service(login, password)
    begin
      service = GCal4Ruby::Service.new
      authenticated = service.authenticate(login, password) 
      return service 
    rescue 
      
    end
    
    return nil
  end
end
