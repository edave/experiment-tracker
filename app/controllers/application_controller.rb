# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  rescue_from 'Acl9::AccessDenied', :with => :access_denied
  
  before_filter :set_current_user
  
  layout 'application'
  
  def signed_in_as_admin?
    signed_in? && current_user.admin?
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
  
  def page_group(value)
    @my_group = value
  end
 
 def development_env?
   Rails.env.development?
 end
 
 def production_env?
   Rails.env.production?
 end
 
   def use_markdown_editor=(value)
    @use_markdown_editor = (value)
  end
  
  def use_markdown_editor?
    return @use_markdown_editor
  end
  
  def render_optional_error_file(status_code)
    if status_code == :not_found
      render_404
    else
      super
    end
  end
    
  $DEVELOPER_FLASH = Hash.new()
  
 helper_method  :signed_in_as_admin?, :controller_page_title, :development_env?, :production_env?, :use_markdown_editor=, :use_markdown_editor?

private
 # This method is run a priori so models can know which user is
 # is interacting with them.
 def set_current_user
   unless current_user == nil
  ActiveRecord::Base.current_user_id = current_user.id
  end
 end

  def render_404
  page_title("404 Error")
  respond_to do |type| 
    type.html { render :template => "home/error_404", :layout => 'application', :status => 404 } 
    type.all  { render :nothing => true, :status => 404 } 
  end
    true  # so we can do "render_404 and return"
  end

  def access_denied
    if current_user
      render :template => 'home/access_denied'
    else
      flash[:notice] = 'Access denied. Try to log in first.'
      redirect_to login_path
    end
  end    

end