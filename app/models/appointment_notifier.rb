class AppointmentNotifier < ActionMailer::Base
  default :from => "noreply@halab-experiments.mit.edu"
  layout 'mailers/default'
  
  def reminder(appointment)
    css 'email'
    
    @subject = 'Reminder'
    setup_email(appointment)
  end
  
  def notice(appointment)
    css 'email'
    @recipient = "#{appointment.slot.experiment.user.email}"
    @subject = 'Signup Notice'
    setup_email(appointment)
  end
  
  def cancelled(appointment)
    css 'email'
    
    @subject = 'Experiment Cancelled'
    setup_email(appointment)
  end
  
  def confirmation(appointment)
    css 'email'
  
    @subject = ' Confirmation'
    setup_email(appointment)
  end
 
  protected
    def setup_email(appointment)
      subject = appointment.subject
      slot = appointment.slot
      @recipient ||=  "#{subject.email}"
      @participant = subject
      @slot = slot
      @experiment = slot.experiment
      @logo_path = slot.experiment.user.group.logo_file_name
      mail(:to => @recipient,
           :subject => slot.experiment.name + " :: " + @subject)

      css 'email'
    end

end
