class PrivilegesController < ApplicationController
  # Controller for managing privileges. Does adhere to the standard
  # rails MVC paradigm, so no refactoring is needed.
  
  before_filter :login_required
  authorize_role [:admin]
  authorize_role :admin, {:only => [:new, :list, :show, :create, :destroy]}
  #ssl_required
  
  def create
     begin
     @privilege = Privilege.new()
     user = User.find(params[:privilege][:user_id])
     role = Role.find(params[:privilege][:role_id])
     @privilege.user = user
     @privilege.role = role
     @privilege.save!
     flash[:notice] = "Privilege successfully created!"
     params[:id] = @privilege.id
     render :action => :show
   rescue ActiveRecord::RecordInvalid
     @users = User.find(:all, :order => "login")
    @roles = Role.find(:all, :order => "name")
        render :action => "new"
    end
  end
  
  def destroy
    @privilege = Privilege.find_by_hashed_id(params[:id])
    @privilege.destroy
    flash[:notice] = "Privilege #" + @privilege.id.to_s + " (" + @privilege.user.login + " as " + @privilege.role.name  +  ") was successfully deleted"
    redirect_to :action => "list"
  end
  
  def list
    page_title("Privileges")
    @privileges = Privilege.find(:all, :include => [:user, :role], :order => "roles.name")
  end
  
  def show
    @privilege = Privilege.find_by_id(params[:id])
    page_title("Privilege \##{@privilege.id}")
  end
  
  def new
    page_title("New Privilege")
    if @privilege.nil?
      @privilege = Privilege.new()
    end
    @users = User.find(:all, :order => "login")
    @roles = Role.find(:all, :order => "name")
  end
end
