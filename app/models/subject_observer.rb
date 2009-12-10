class SubjectObserver < ActiveRecord::Observer
  def after_create(subject)
    SubjectNotifier.deliver_confirmation(subject)
   rescue *SMTP_CLIENT_ERRORS
    
   rescue *SMTP_SERVER_ERRORS => error

  end
end
