class UsersController < ApplicationController
  # Controller for handling Users
  before_filter :login_required, {:except => [:new, :help, :create, :reset, :send_reset, :reset_password, :submit_reset_password, :activate]}
  filter_parameter_logging :password, :confirmation_password, :login, :email, :activation_code, :salt, :name, :phone
  
  #Chaining in an array is an OR- so approve managers or tenants
  authorize_role [:admin, :experimenter], {:except => [:new, :help, :create, :reset, :send_reset, :reset_password, :submit_reset_password, :activate]}
  authorize_role :admin, {:only => [:list, :show, :destroy]}
  
  def ssl_required?
     return false #BigliettoConfig.use_ssl
  end
  
  # new tenant:
  def new
    page_title('Signup')
    @user = User.new()
    #unless allow_user_signup || ( logged_in? && user_admin? )
    #   redirect_back_or_default("/")
    #end
  end
 

  def update
    @user = User.find_by_hashed_id(params[:id])
    user_id = @user.id if @user
    begin
    if logged_in? && (self.current_user.id.to_i == user_id.to_i || self.user_admin?)
      flash.sweep
    
      if @user.update_attributes(params[:user])
        flash[:notice] = "Thanks, we got your changes!"
        @user.reload
      else
        flash[:warning] = "We were unable to make your changes, please check for errors below"
      end
      render :action => :edit, :params => {:id => params[:id]}
    else
      flash[:notice] = "You cannot edit that user"
      @user = nil
      return access_denied
    end
    
    rescue ActiveRecord::RecordInvalid
        render :action => "edit", :id => params[:id]
    end
  end
  
  def edit
    page_title('Edit your information')
    @user = User.find_by_hashed_id(params[:id])
    user_id = @user.id if @user
    if  logged_in? && (self.current_user_id == user_id.to_i  || self.user_admin? )
      @cu = self.current_user
      #flash[:notice] = "You're editing!"
    else
      flash[:notice] = "Action not allowed"
      @user = nil
      access_denied
    end
    
  end
  
  def show
    @user = User.find_by_hashed_id(params[:id])
    page_title(["Users", "#{@user.login} (#{@user.hashed_id})"])
    user_id = @user.id if @user
    if logged_in? && self.user_admin?
      @user = User.find_by_id(user_id)
      #flash[:notice] = "You're showing!"
    else
      flash[:notice] = "Action not allowed"
      @user = nil
      redirect_back_or_default("/")
    end
  end
  
  def list
    page_title("Users")
    if self.logged_in? and self.user_admin?
      @users = User.find(:all)
    end
  end

  def create
    @user = User.new(params[:user])
    User.transaction do
        Privilege.transaction do
        @user.save!
        @user.reload
        current_user = @user
        current_user_id = @user.id
         #Create the necessary privileges
        @privilege = Privilege.new()
        @privilege.user = @user
        
        @privilege.role = Role.find_by_slug("experimenter")
       
        ActiveRecord::Base.current_user_id = current_user_id
        @privilege.save!
        current_user = nil
        UserNotifier.deliver_activation(@user)
      
        end
  end
  rescue ActiveRecord::RecordInvalid
    render :template => "users/new"
  end
  
  def activate
    @user = User.find_by_activation_code(params[:id])
    if @user
      @user.activate
    end
  end
# Disabled for now (along with its tests) - we'll revisit this later
=begin
  def destroy
    user_id = params[:id]
    if logged_in? && (self.current_user.id.to_i == user_id.to_i || user_admin? )
      @user = User.find_by_id(user_id)
      @user.deactivate!
      if @user.id == current_user_id
        flash[:notice] = "Your account has been deactivated"
        render :controller => 'session', :action => 'destroy'
        return
      end
    end
    access_denied
  end
=end
  def help
    page_title('Help')
  end

  def reset
    page_title('Reset your password')
    flash.clear
    render :layout => 'external'
  end
  
  def send_reset
    flash.clear
    page_title('Reset instructions emailed')
    
    user = User.find_by_email_and_login(params[:email], params[:login])
    unless user.blank?
      email = UserNotifier.create_reset(user)
      $DEVELOPER_FLASH[:reset] = "<a href='/user/reset_password?email=#{user.email}&recover_code=#{user.recover_code}'>link</a>"
      UserNotifier.deliver(email)
    else
      flash[:error] = "The login and/or email address you gave could not be found, please try again."
      redirect_to :controller=> 'user', :action=>'reset'
      return
    end
    render :layout => 'external'
    #Send email w/ link to reset_password
  end
  
  def reset_password
    # We ID by email address so that the user is required to know two pieces
    # of information to request a recover (login and email), but only one 
    # piece of information is sent around. Since we are emailing them a 
    # link for the password recover, the email address has already been exposed
    # 
    # The recover code is added to prevent a malicious user from trying to change
    # passwords simply by knowing the email address
    flash.clear
    page_title('Account Confirmation')
    
    user = User.find_by_recover_code_and_email(params[:recover_code], params[:email])
    if user == nil
      flash[:error] = "Recover code not found"
      @user_not_found = true
    elsif user.can_reset_password?
      @user = user
      @email = params[:email]
      @recover_in_process_code = user.generate_recover_in_process_code
    else
      @user_not_found = true
    end
     render :layout => 'external'
  end
  
  def submit_reset_password
    flash.clear
    page_title('Change your password')
    
    user = User.find_by_login_and_email_and_recover_in_process_code(params[:login], params[:email], params[:recover_in_process_code])
    if user == nil
      flash[:error] = "User account not found"
      @user_not_found = true
    elsif user.recover_in_process?
      if user.update_attributes(:password => params[:password], :password_confirmation => params[:password_confirmation])
        flash[:notice] = "Your password was changed"
      else
        flash[:error] = "Bad password choice"
        render :layout => 'external', :action => "reset_password"
        return
      end
    end
     render :layout => 'external'
   rescue ActiveRecord::RecordInvalid
        flash[:error] = 'Error in finding your account'
        render :action => "reset_password"    
  end
  
  def unfreeze
    @user = User.find_by_hashed_id(params[:id])
    begin
    if logged_in? && self.user_admin?
      flash.sweep
      @user.failure = 0
      @user.last_failed_at = nil
      
      @user.save
        flash[:notice] = "#{@user.login} was unfrozen and can now sign in"
        @user.reload
      redirect_to :action => :show, :params => {:id => params[:id]}
    else
      flash[:notice] = "You cannot unfreeze that user"
      @user = nil
      return access_denied
    end
    
    rescue ActiveRecord::RecordInvalid
        render :action => "show", :id => params[:id]
    end
  end
  
end
