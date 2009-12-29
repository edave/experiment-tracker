class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserNotifier.deliver_signup_notification(user) unless user.silently_update?
  end

  def after_save(user)
    if user.email_changed?
      # Although in practice we try to limit a 1->1 relationship
      # for the accounts, there are no hard checks in place and 
      # our unit tests reuse the user, so we need to cycle through 
      # to set all the tenants which have been associated with this user
      
      if tenants = Tenant.find_all_by_user_id(user.id)
        tenants.each do |tenant|
        tenant.email = user.email
        tenant.save!
        end
      end
      if managers = Manager.find_all_by_user_id(user.id)
        managers.each do |manager|
        manager.email = user.email
        manager.save!
        end
      end
    end
    
    UserNotifier.deliver_activation(user) if user.recently_activated?
    UserNotifier.deliver_password_changed(user) if user.password_changed? and !user.silently_update?
   rescue *SMTP_CLIENT_ERRORS
    
   rescue *SMTP_SERVER_ERRORS => error
    notify_hoptoad error
  end
  
  def delete(user)
    UserNotifier.deliver_delete(user) if user.recently_deleted?
    rescue *SMTP_CLIENT_ERRORS
    
   rescue *SMTP_SERVER_ERRORS => error
    notify_hoptoad error
  end
end
