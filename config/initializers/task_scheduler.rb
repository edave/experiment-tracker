scheduler = Rufus::Scheduler::PlainScheduler.start_new(:frequency => 60.0)

def scheduler.handle_exception (job, exception)
    Rails.logger.warn "#{Time.now} :: Rufus Scheduler :: job #{job.job_id} caught exception\n#{exception.message}\n#{exception.backtrace.join("\n")}"
  end

scheduler.cron '0 22 * * *', :timeout => '30m' do
   Rails.logger.info "#{Time.now} :: Starting participant notifier task..."
   slots = Slot.find_by_occupied.find_by_day(Date.tomorrow)
   for slot in slots
     SlotNotifier.deliver_reminder(slot)
    end
 Rails.logger.info "#{Time.now} :: Participant notifier task finished: #{slots.length} notified"
   
end

scheduler.in "5s" do #cron '0 22 * * *' do
   Rails.logger.info "#{Time.now} :: Special Starting participant notifier task..."
   slots = Slot.find_by_occupied.find_by_day(Date.today)
   for slot in slots
     SlotNotifier.deliver_reminder(slot)
    end
 Rails.logger.info "#{Time.now} :: Special Participant notifier task finished: #{slots.length} notified"
   
end 

scheduler.cron '0 23 * * *', :timeout => '30m' do
  Rails.logger.info "#{Time.now} :: Starting experiment schedule notifier task..."
  experiments = Experiment.find(:all)
  day = Date.tomorrow
  for experiment in experiments
    if experiment.occupied_slots(day).length > 0
      ExperimentNotifier.deliver_schedule(experiment)
    end
  end
  Rails.logger.info "#{Time.now} :: Finished experiment schedule notifier task..."
  
end