class PrivilegesController < ApplicationController
  # Controller for managing privileges. Does adhere to the standard
  # rails MVC paradigm, so no refactoring is needed.
  
  #before_filter :login_required
  #authorize_role [:admin]
  
  def create
     begin
     @privilege = Privilege.new()
     user = User.find(params[:privilege][:user_id])
     role = Role.find(params[:privilege][:role_id])
     @privilege.user = user
     @privilege.role = role
     @privilege.save!
     flash[:notice] = "Privilege successfully created!"
     params[:id] = @privilege.hashed_id
     render :action => :show, :id => @privilege.hashed_id
   rescue ActiveRecord::RecordInvalid
     flash[:notice] = "Privilege creation failed"
     @users = User.order("email")
     @roles = Role.order("name")
        render :action => "new"
    end
  end
  
  def destroy
    @privilege = Privilege.obfuscated(params[:id])
    @privilege.destroy
    flash[:notice] = "Privilege #" + @privilege.id.to_s + " (" + @privilege.user.user_name + " as " + @privilege.role.name  +  ") was successfully deleted"
    redirect_to :action => "index"
  end
  
  def index
    page_title("Privileges")
    @privileges = Privilege.includes(:user, :role).order("roles.name")
  end
  
  def show
    @privilege = Privilege.obfuscated(params[:id])
    page_title("Privilege \##{@privilege.id}")
  end
  
  def new
    page_title("New Privilege")
    if @privilege.nil?
      @privilege = Privilege.new()
    end
    @users = User.order("email")
    @roles = Role.order("name")
  end
end
