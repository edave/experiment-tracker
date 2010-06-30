class ProcessAppointmentTask < Rooster::Task
  
  @tags = ['ProcessAppt'] # CUSTOMIZE:  add additional tags here
  Rooster::Runner.logger = Logger.new(File.join(Rails.root, "log", "rooster.log"))
  
  define_schedule do |s|
    s.every "1m", :first_at => Chronic.parse("now"), :tags => @tags do  # CUSTOMIZE:  reference http://github.com/jmettraux/rufus-scheduler/tree/master
      begin
        log "#{self.name} starting at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection.reconnect!
        appointments_scheduled = 0
        appointments = Appointment.find(:all, :conditions => ["scheduled_in_background = ?", false], :include => :slot)
        for appointment in appointments do
          #SlotNotifier.deliver_confirmation(slot)
          slot = appointment.slot
          calendar = slot.experiment.google_calendar
          if calendar != nil
            calendar.add_scheduled_slot(slot.experiment, slot, appointment.subject)
          end
          AppointmentNotifier.deliver_confirmation(appointment)
          #if slot.experiment.send_appointment_notifications? 
          #  AppointmentNotifier.deliver_experimenter_confirmation(appointment)
          #end
          appointment.scheduled_in_background = true
          appointment.save
          appointments_schedule += 1
        end
        
      ensure
        log "#{self.name} completed at #{Time.now.to_s(:db)}, #{appointments_scheduled.to_s} processed"
        ActiveRecord::Base.connection_pool.release_connection
    end
    end
  end
end