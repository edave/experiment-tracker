require "uri"
module AuthenticatedSystem
  # The Authenticated System handles the nitty-gritty details of logging Users in and out
  # It sets a lot of variables related to the logged in User as well the necessary cookies, etc
  
  def get_current_user
    return current_user
  end
  
  protected
  
    # Deprecated, we should hunt and destroy this method
    def user_admin?
      self.current_user.has_role?(:admin)
    end
  
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      #current_user != :false
      !session[:user].nil?
    end
    
    # Accesses the current user from the session.
    def current_user
     unless session[:user].nil?
       user = User.find_by_id(session[:user])
       return current_user = user
     end
     @current_user = :false
   end
   
   def current_user_id
     session[:user]
   end
    
    # Store the given user in the session.
    def current_user=(new_user)
      unless new_user.nil? or new_user.is_a?(Symbol) or new_user.deactivated?
      session[:user] =  new_user.id
      @current_user = new_user
    else
      session[:user] = nil
      @current_user = :false
      end
    end
    
    # Check if the user is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_user.login != "bob"
    #  end
    def authorized?(current_user)
      # Not implemented
    end
    
    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      push_location_for_redirect
      logged_in? ? true : access_denied
    end
    
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to :controller => 'sessions', :action => 'denied'
        end
        accepts.xml do
          request_http_basic_authentication "Web Password"
        end
      end
      false
    end  
    
    def push_location_for_redirect
      session[:return_to] = nil
      redirect_stack = session[:redirect_stack]
      redirect_stack ||= Array.new()
      redirect_stack.push(request.request_uri)
      # If the stack exceeds the size we want, we drop the last element to maintain a consistent size
      if redirect_stack.size > 2
        redirect_stack.slice!(-1) # Remove last element
      end
      session[:redirect_stack] = redirect_stack
    end
    
    def should_redirect_back
      return !session[:return_to].blank?
    end
    
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      if session[:return_to] # First handle "Access Denied" redirects
        redirect_uri = session[:return_to]
        session[:return_to] = nil
        redirect_to(redirect_uri)
        return
      elsif session[:redirect_stack]
        redirect_stack = session[:redirect_stack]
        redirect_uri = redirect_stack.pop()
        while redirect_uri && redirect_uri == request.request_uri
          redirect_uri = redirect_stack.pop()
        end
        session[:redirect_stack] = redirect_stack
        if redirect_uri && redirect_uri != request.request_uri
          redirect_to(redirect_uri)
          return
        end
        
      end
      redirect_to(default)
    end
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :currend_user_id
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless cookies[:auth_token] && !logged_in?
      user = User.find_by_remember_token(cookies[:auth_token])
      
      if user && user.remember_token? && !user.deactivated?
        self.current_user = user
        account_setup_user
        flash[:notice] = "Welcome back!"
      end
  end
end
