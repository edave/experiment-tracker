class SlotNotifier < ActionMailer::Base
  layout 'mailers/default'
 
  
  
  protected
    def setup_email(slot, subject)
      @recipients  = "#{subject.email}"
      @from        = "noreply@halab-experiments.mit.edu"
      @subject     = slot.experiment.name + " :: "
      @sent_on     = Time.now
      @body[:participant] = subject
      @body[:slot] = slot
      @body[:experiment] = slot.experiment
      content_type "text/html"

      css 'email'
    end
end
