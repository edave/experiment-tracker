class RemindParticipantsTask < Rooster::Task
  
  @tags = ['RemindParticipants'] # CUSTOMIZE:  add additional tags here
    Rooster::Runner.logger = Logger.new(File.join(Rails.root, "log", "rooster.log"))
    
  define_schedule do |s|
      s.every "1d", :first_at => Chronic.parse("9:30pm"), :tags => @tags do  # CUSTOMIZE:  reference http://github.com/jmettraux/rufus-scheduler/tree/master
      begin
        log "#{self.name} starting at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection.reconnect!
        experiments = Experiment.find(:all)
        day = Date.tomorrow
        for experiment in experiments
            log "Experiment: #{experiment.name}"
            if experiment.is_occupied(day)
              ExperimentNotifier.deliver_schedule(experiment, day)
            end
            slots = experiment.occupied_slots(day)
            for slot in slots
              log "Slot: #{slot.human_datetime}"
              
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