class AppointmentNotifier < ActionMailer::Base
  layout 'mailers/default'
  def reminder(appointment)
    setup_email(appointment)
    css 'email'
    
    @subject    += 'Reminder'
  end
  
  def cancelled(appointment)
    setup_email(appointment)
    css 'email'
    
    @subject    += 'Experiment Cancelled'
  end
  
  def confirmation(appointment)
    setup_email(appointment)
    css 'email'
  
    @subject    += ' Confirmation'
  end
 
  protected
    def setup_email(appointment)
      subject = appointment.subject
      slot = appointment.slot
      @recipients  = "#{subject.email}"
      @from        = "noreply@halab-experiments.mit.edu"
      @subject     = slot.experiment.name + " :: "
      @sent_on     = Time.now
      @body[:participant] = subject
      @body[:slot] = slot
      @body[:experiment] = slot.experiment
      @body[:logo_path] = slot.experiment.user.group.logo_file_name
      content_type "text/html"

      css 'email'
    end

end
