class RemindExperimenterTask < Rooster::Task
  
  @tags = ['RemindExperimenter'] # CUSTOMIZE:  add additional tags here
  Rooster::Runner.logger = Logger.new(File.join(Rails.root, "log", "rooster.log"))
  
  define_schedule do |s|
     s.every "1m", :first_at => Chronic.parse("now"), :tags => @tags do #s.every "1d", :first_at => Chronic.parse("9:30pm"), :tags => @tags do  # CUSTOMIZE:  reference http://github.com/jmettraux/rufus-scheduler/tree/master
      begin
        log "#{self.name} starting at #{Time.now.to_s(:db)}"
       #  ActiveRecord::Base.connection.reconnect!
      #   experiments = Experiment.find(:all)
        #day = Date.tomorrow
        #processed = 0
        #experiments.each do |experiment|
        #  log "Experiment: #{experiment.name}"
        #  
         # if experiment.occupied?.length > 0
        #    ExperimentNotifier.deliver_schedule(experiment)
        #    processed += 1
        #  end
        #end
      ensure
        log "#{self.name} completed at #{Time.now.to_s(:db)}, #{processed} processed"
        ActiveRecord::Base.connection_pool.release_connection
      end
    end
  end
end