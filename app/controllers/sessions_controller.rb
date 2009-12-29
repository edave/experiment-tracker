# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  # include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  # before_filter :login_from_cookie
  filter_parameter_logging :password, :login, :hashedpassword, :temp_salt, :auth_token
  layout "external"
  #ssl_required :new, :create
 
  # Essentially the "login" screen
  def new
    page_title("Signin")
    if logged_in?
      
    end
  end

  # The actual authentication. The commented out lines related to using JS to login instead of SSL
  def create
    #if params[:hashedpassword].blank?
      self.current_user = User.authenticate(params[:login], params[:password], nil, request.remote_ip)
    #else
      #self.current_user = User.authenticate(params[:login], params[:hashedpassword], session[:temp_salt], request.remote_ip)
    #end
    
    if logged_in?
      flash[:notice] = nil #Clear the flash notice
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      
      session[:temp_salt] = nil
        
        if should_redirect_back
          
          redirect_back_or_default('/')
        else
          redirect_to('/')
        end
        return
      
    elsif User.locked_out?(params[:login]) # TODO - Optimize User.locked_out? given we're accessing the same user above.
      flash[:warning] = "Account Locked Out :: Sorry! Recently someone has tried, and failed, to access your account too many times. Please contact Support"
      render :action => 'new'
    else #logged_in? is false
      flash[:warning] = "Incorrect login and/or password"
      render :action => 'new'
      
    end
  end

  # Logout
  def destroy
    page_title("Signed Out")
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You are now signed out."
    render :action => 'new'
  end
  
  # Access Denied, either due to not being logged in or not having
  # the necessary privileges. We could put in better error messages
  # for our users eventually
  def denied
    page_title("Access Denied")
    if logged_in?
     
    end
  end
  
  # Convenience Method
  def logout
    self.destroy
  end
end
