class SlotNotifier < ActionMailer::Base
  
  def reminder(slot)
    setup_email(slot)
    layout 'default'
    css 'default'
    
    @subject    += 'Reminder'
  end
  
  def cancelled(slot)
    setup_email(slot)
    layout 'default'
    css 'default'
    
    @subject    += 'Experiment Cancelled'
  end
  
  def confirmation(slot)
    setup_email(slot)
    layout 'default'
    css 'default'
    
    @subject    += ' Confirmation'
  end
 
  protected
    def setup_email(slot)
      @recipients  = "#{slot.subject.email}"
      @from        = "noreply@halab-experiments.mit.edu"
      @subject     = "HALab Study :: "
      @sent_on     = Time.now
      @body[:participant] = slot.subject
      @body[:slot] = slot
      @body[:experiment] = slot.experiment
      content_type "text/html"

      layout 'default'
      css 'default'
    end
end
