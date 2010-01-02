class ProcessSlotTask < Rooster::Task
  
  @tags = ['ProcessSlot'] # CUSTOMIZE:  add additional tags here
  
  define_schedule do |s|
    s.every "1m", :first_at => Chronic.parse("next 2:00am"), :tags => @tags do  # CUSTOMIZE:  reference http://github.com/jmettraux/rufus-scheduler/tree/master
      begin
        log "#{self.name} starting at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection.reconnect!

        slots = Slot.find(:all, :conditions => {:scheduled_in_background => false})
        for slot in slots do
          SubjectNotifier.deliver_confirmation(slot.subject)
          calendar = slot.experiment.google_calendar
          if calendar != nil?
            calendar.add_scheduled_slot(@experiment, @slot, @subject)
          end
          slot.scheduled_in_background = true
          slot.save
        end
        
      ensure
        log "#{self.name} completed at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
  end
end