scheduler = Rufus::Scheduler::PlainScheduler.start_new

scheduler.cron '0 22 * * *' do
   slots = Slot.find_by_day(Date.tomorrow).find_by_occupied
   for slot in slots
     SlotNotifier.deliver_reminder(slot)
   end
end 

scheduler.cron '0 23 * * *' do
  experiments = Experiment.find(:all)
  day = Date.tomorrow
  for experiment in experiments
    if experiment.occupied_slots(day).length > 0
      ExperimentNotifier.deliver_schedule(experiment)
    end
  end
end