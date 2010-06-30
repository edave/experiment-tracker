class RemindParticipantsTask < Rooster::Task
  
  @tags = ['RemindParticipants'] # CUSTOMIZE:  add additional tags here
    Rooster::Runner.logger = Logger.new(File.join(Rails.root, "log", "rooster.log"))
    
  define_schedule do |s|
     s.every "1d", :first_at => Chronic.parse("9:30pm"), :tags => @tags do  # CUSTOMIZE:  reference http://github.com/jmettraux/rufus-scheduler/tree/master
      begin
        log "#{self.name} starting at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection.reconnect!
        experiments = Experiment.find(:all)
        for experiment in experiments
            slots = Slot.find_by_occupied(experiment).find_by_day(Date.tomorrow)
            for slot in slots
             slot.appointments.each do |appointment|
              AppointmentNotifier.deliver_reminder(appointment)
             end
            end
        end
      ensure
        log "#{self.name} completed at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
  end
end