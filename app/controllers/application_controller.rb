# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :email, :name
  
  helper_method :signed_in_as_admin?
  
  def signed_in_as_admin?
    signed_in? && current_user.admin?
  end
  
  def users_only
    deny_access("Please Login or Create an Account to Access that Feature.") unless signed_in?
  end
  
  def admin_only
    deny_access("Please Login as an administrator to Access that Feature.") unless signed_in_as_admin?
  end
  
  def controller_page_title(value)
    @my_page_title = [value]
  end
  
  def page_title(value)
    @my_page_title ||= []
    if value.kind_of? String
      @my_page_title << value
    elsif value.kind_of? Array
      @my_page_title += value
    end
  end
 
 def development_env?
   ENV['RAILS_ENV'] == 'development'
 end
 
 def production_env?
   ENV['RAILS_ENV'] == 'production'
 end
 
   def use_markdown_editor=(value)
    @use_markdown_editor = (value)
  end
  
  def use_markdown_editor?
    return @use_markdown_editor
  end
  
  
 helper_method :development_env?, :production_env?, :use_markdown_editor=, :use_markdown_editor?

end
