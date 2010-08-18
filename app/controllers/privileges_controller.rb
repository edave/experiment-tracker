class PrivilegesController < ApplicationController
  # Controller for managing privileges. Does adhere to the standard
  # rails MVC paradigm, so no refactoring is needed.
  
  #before_filter :login_required
  #authorize_role [:admin]
  
  def create
     begin
     @privilege = Privilege.new()
     user = User.where(params[:privilege][:user_id])
     role = Role.where(params[:privilege][:role_id])
     @privilege.user = user
     @privilege.role = role
     @privilege.save!
     flash[:notice] = "Privilege successfully created!"
     params[:id] = @privilege.id
     render :action => :show
   rescue ActiveRecord::RecordInvalid
     @users = User.order("login")
    @roles = Role.order("name")
        render :action => "new"
    end
  end
  
  def destroy
    @privilege = Privilege.obfuscated(params[:id])
    @privilege.destroy
    flash[:notice] = "Privilege #" + @privilege.id.to_s + " (" + @privilege.user.login + " as " + @privilege.role.name  +  ") was successfully deleted"
    redirect_to :action => "list"
  end
  
  def index
    page_title("Privileges")
    @privileges = Privilege.all.includes(:user, :role).order("roles.name")
  end
  
  def show
    @privilege = Privilege.where(params[:id])
    page_title("Privilege \##{@privilege.id}")
  end
  
  def new
    page_title("New Privilege")
    if @privilege.nil?
      @privilege = Privilege.new()
    end
    @users = User.order("login")
    @roles = Role.order("name")
  end
end
