class SlotNotifier < ActionMailer::Base
  
  def reminder(slot, subject)
    setup_email(slot, subject)
    layout 'default'
    css 'default'
    
    @subject    += 'Reminder'
  end
  
  def cancelled(slot, subject)
    setup_email(slot, subject)
    layout 'default'
    css 'default'
    
    @subject    += 'Experiment Cancelled'
  end
  
  def confirmation(slot, subject)
    setup_email(slot, subject)
    layout 'default'
    css 'default'
  
    @subject    += ' Confirmation'
  end
 
  protected
    def setup_email(slot, subject)
      @recipients  = "#{subject.email}"
      @from        = "noreply@halab-experiments.mit.edu"
      @subject     = "HALab Study :: "
      @sent_on     = Time.now
      @body[:participant] = subject
      @body[:slot] = slot
      @body[:experiment] = slot.experiment
      content_type "text/html"

      layout 'default'
      css 'default'
    end
end
