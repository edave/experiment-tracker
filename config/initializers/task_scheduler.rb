scheduler = Rufus::Scheduler::PlainScheduler.start_new

scheduler.cron '0 22 * * *' do
   slots = Slot.find_by_day(Date.tomorrow)
   for slot in slots
     unless slot.subject.nil?
      SlotNotifier.deliver_reminder(slot)
     end
   end
end 