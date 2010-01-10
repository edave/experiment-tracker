class UserNotifier < ActionMailer::Base
  # Handles emails for the User model
  layout 'mailers/default'
    
  def delete_notification(user)
    setup_email(user)
    css 'email'
    @subject += "Your account has been deleted."
   
 end
 
  
  def activation(user)
    setup_email(user)
    css 'email'
    @subject    += 'Activate your account'
  end
  
  def password_changed(user)
    setup_email(user)
    css 'email'
    @subject += 'Your password has been changed'
  end
  
  def reset(user)
    setup_email(user)
    css 'email'
    @body[:url] = url_for :host =>  BigliettoConfig.host, :controller => 'user', :action => "reset_password", :recover_code => user.generate_recover_code, :email => user.email, :only_path => false, :protocol => 'https'
    @subject += 'Change your account password'
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = BigliettoConfig.sender_email_address
      @subject     = BigliettoConfig.app_name + " :: "
      @sent_on     = Time.now
      @body[:user] = user
      @body[:url]  = BigliettoConfig.host
      #content_type    "multipart/alternative"
    end
end
