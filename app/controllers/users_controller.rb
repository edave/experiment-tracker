class UsersController < ApplicationController
  # Controller for handling Users
  before_filter :authenticate_user!, :except => [:sign_in, :sign_up, :sign_out]
  
  access_control do
    allow anonymous
    
    actions :sign_in, :sign_up, :sign_out do
      allow all
    end
    
  end
     
     
  def new
    page_title('Signup')
    @user = User.new()
    @groups = Group.all
  end
 

  def update
    @user = User.obfuscated(params[:id])
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
    @user = User.obfuscated(params[:id])
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
    @user = User.obfuscated(params[:id])
    page_title(["Users", "#{@user.login} (#{@user.hashed_id})"])
    user_id = @user.id if @user
    if logged_in? && (user_id == current_user_id || self.user_admin?)
      #flash[:notice] = "You're showing!"
    else
      flash[:notice] = "Action not allowed"
      @user = nil
      redirect_back_or_default("/")
    end
  end
  
  def index
    page_title("Users")
    if self.logged_in? and self.user_admin?
      @users = User.all
    else
      access_denied
      return
    end
  end

end
