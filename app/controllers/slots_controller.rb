class SlotsController < ApplicationController
  before_filter :login_required
  authorize_role [:admin, :experimenter]
  authorize_role :admin, {:only => [:cancel]}
  
  # GET /slots
  # GET /slots.xml
  def index
    @experiment = Experiment.find_by_hashed_id(params[:experiment])
    unless !@experiment.nil? or @experiment.can_modify?(current_user)
      access_denied
      return
    end
    @slots = Slot.find(:all, :conditions => {:experiment_id => @experiment.id}, :order => "time")
    page_title([@experiment.name, "Time Slots"])
    @filled_slots = Slot.find_by_occupied(@experiment).length
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @slots }
    end
  end

  # GET /slots/1
  # GET /slots/1.xml
  def show
    
    @slot = Slot.find_by_hashed_id(params[:id], :include => :experiment)
    @experiment = @slot.experiment
    unless !@experiment.nil? or @experiment.can_modify?(current_user)
      access_denied
      return
    end
    if @experiment.can_modify?(current_user)
    page_title([@experiment.name, "Slot", @slot.human_time])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @slot }
    end
    else
      
    end
  end

  # GET /slots/new
  # GET /slots/new.xml
  def new
    page_title("New Time Slot")
    @slot = Slot.new
    @experiment = Experiment.find_by_hashed_id(params[:id], :include => [:slots])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @slot }
    end
  end

  def cancel
    @slot = Slot.find_by_hashed_id(params[:id], :include => :experiment)
    @experiment = @slot.experiment
    unless !@experiment.nil? or @experiment.can_modify?(current_user)
      access_denied
      return
    end
    page_title([@experiment.name, "Slot Cancelled", @slot.human_time])
    if @experiment.can_modify?(current_user)
    @slot.cancelled = true
    @slot.save!
    
    SlotNotifier.deliver_cancelled(@slot)
    end
    respond_to do |format|
      format.html
      format.xml  { render :xml => @slot }
    end
  end

  # GET /slots/1/edit
  def edit
    
    @slot = Slot.find_by_hashed_id(params[:id], :include => :experiment)
    @experiment = @slot.experiment
    unless !@experiment.nil? or @experiment.can_modify?(current_user)
      access_denied
      return
    end
    if @experiment.owned_by?(current_user)
    page_title([@experiment.name, "Edit Slot", @slot.human_time])
    else
    redirect_to(:controller => :slots, :action => :index, :id=> @experiment.hashed_id)
    end
  end

  # POST /slots
  # POST /slots.xml
  def create
    @slot = Slot.new(params[:slot])
    @experiment = Experiment.find_by_hashed_id(params[:experiment_id])
    unless !@experiment.nil? or @experiment.can_modify?(current_user)
      access_denied
      return
    end
    @slot.experiment = @experiment
    respond_to do |format|
      if @experiment.can_modify?(current_user) and @slot.save
        flash[:notice] = 'Slot was successfully created.'
        format.html { redirect_to(@slot.experiment) }
        format.xml  { render :xml => @slot, :status => :created, :location => @slot }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @slot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /slots/1
  # PUT /slots/1.xml
  def update
    @slot = Slot.find_by_hashed_id(params[:id], :include => :experiment)
    @experiment = @slot.experiment
    unless !@experiment.nil? or @experiment.can_modify?(current_user)
      access_denied
      return
    end
    respond_to do |format|
      if @experiment.can_modify?(current_user) and @slot.update_attributes(params[:slot])
        flash[:notice] = 'Slot was successfully updated.'
        format.html { redirect_to(@slot) }
        format.xml  { head :ok }
      else
        
        format.html { render :action => "edit" }
        format.xml  { render :xml => @slot.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /slots/1
  # DELETE /slots/1.xml
  def destroy
    @slot = Slot.find_by_hashed_id(params[:id], :include => :experiment)
    @experiment = @slot.experiment
    unless !@experiment.nil? or @experiment.can_modify?(current_user)
      access_denied
      return
    end
    if @experiment.can_modify?(current_user)
      @slot.destroy
    end
    respond_to do |format|
      format.html { redirect_to(@experiment) }
      format.xml  { head :ok }
    end
  end
end
