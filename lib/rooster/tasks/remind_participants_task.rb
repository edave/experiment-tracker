class RemindParticipantsTask < Rooster::Task
  
  @tags = ['RemindParticipants'] # CUSTOMIZE:  add additional tags here
  
  define_schedule do |s|
    s.every "1d", :first_at => Chronic.parse("next 2:00am"), :tags => @tags do  # CUSTOMIZE:  reference http://github.com/jmettraux/rufus-scheduler/tree/master
      begin
        log "#{self.name} starting at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection.reconnect!
        slots = Slot.find_by_occupied.find_by_day(Date.tomorrow)
          for slot in slots
          SlotNotifier.deliver_reminder(slot)
        end
      ensure
        log "#{self.name} completed at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
  end
end