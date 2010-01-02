class RemindExperimenterTask < Rooster::Task
  
  @tags = ['RemindExperimenter'] # CUSTOMIZE:  add additional tags here
  
  define_schedule do |s|
    s.every "1d", :first_at => Chronic.parse("next 2:00am"), :tags => @tags do  # CUSTOMIZE:  reference http://github.com/jmettraux/rufus-scheduler/tree/master
      begin
        log "#{self.name} starting at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection.reconnect!
        experiments = Experiment.find(:all)
        day = Date.tomorrow
        for experiment in experiments
          if experiment.occupied_slots(day).length > 0
            ExperimentNotifier.deliver_schedule(experiment)
          end
        end
        log "#{self.name} completed at #{Time.now.to_s(:db)}"
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
  end
end