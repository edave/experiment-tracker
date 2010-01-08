class ExperimentsController < ApplicationController
  before_filter :login_required, {:except => [:filled, :participate]}
  authorize_role [:admin, :experimenter], {:except => [:filled, :participate]}
  
  # GET /experiments
  # GET /experiments.xml
  def index
    @experiments = Experiment.find_all_by_user_id(current_user.id)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @experiments }
    end
  end

  # GET /experiments/1
  # GET /experiments/1.xml
  def show
    @experiment = Experiment.find_by_hashed_id(params[:id], :include => :slots)
    if @experiment.nil? or !@experiment.can_modify?(current_user)
      access_denied
      return
    end
    page_title(@experiment.name)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @experiment }
    end
  end
  
  def filled
    @experiment = Experiment.find_by_hashed_id(params[:id])
    page_title(@experiment.name + " is full")
    
    render :layout => 'external'
  end
  
  def participate
    @experiment = Experiment.find_by_hashed_id(params[:id])
    unless @experiment.open? or @experiment.can_modify?(current_user)
      access_denied
      return
    end
    page_title(@experiment.name)
    
    render :layout => 'external'
  end

  # GET /experiments/new
  # GET /experiments/new.xml
  def new
    page_title("New Experiment")
    
    @experiment = Experiment.new
    @calendars = self.calendars_select_array()
    @locations = self.locations_select_array()
    self.use_markdown_editor = true
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @experiment }
    end
  end

  # GET /experiments/1/edit
  def edit
    @experiment = Experiment.find_by_hashed_id(params[:id])
    page_title(["Editing",@experiment.name])
    
    if @experiment.nil? or !@experiment.can_modify?(current_user)
      access_denied
      return
    end
    @calendars = self.calendars_select_array()
    @locations = self.locations_select_array()
    self.use_markdown_editor = true
   
  end

  # POST /experiments
  # POST /experiments.xml
  def create
    @experiment = Experiment.new(params[:experiment])
    @experiment.user = current_user
    location = Location.find_by_hashed_id(params[:location_id])
    @experiment.location = location
    calendar = GoogleCalendar.find_by_hashed_id(params[:calendar_id])
    @experiment.google_calendar = calendar
    respond_to do |format|
      if @experiment.save
        flash[:notice] = 'Experiment was successfully created.'
        format.html { redirect_to(:controller => :experiments, :action => :show, :id => @experiment.hashed_id) }
        format.xml  { render :xml => @experiment, :status => :created, :location => @experiment }
      else
        @calendars = self.calendars_select_array()
    @locations = self.locations_select_array()
    self.use_markdown_editor = true
    
        format.html { render :action => "new" }
        format.xml  { render :xml => @experiment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /experiments/1
  # PUT /experiments/1.xml
  def update
    @experiment = Experiment.find_by_hashed_id(params[:id])
    if @experiment.nil? or !@experiment.can_modify?(current_user)
      access_denied
      return
    end
    location = Location.find_by_hashed_id(params[:location_id])
    @experiment.location = location
    calendar = GoogleCalendar.find_by_hashed_id(params[:calendar_id])
    @experiment.google_calendar = calendar
    respond_to do |format|
      if @experiment.update_attributes(params[:experiment])
        flash[:notice] = 'Experiment was successfully updated.'
        format.html { redirect_to(@experiment) }
        format.xml  { head :ok }
      else
      @calendars = self.calendars_select_array()
      @locations = self.locations_select_array()
      self.use_markdown_editor = true
        format.html { render :action => "edit" }
        format.xml  { render :xml => @experiment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /experiments/1
  # DELETE /experiments/1.xml
  def destroy
    @experiment = Experiment.find_by_hashed_id(params[:id])
    if @experiment.nil? or !@experiment.can_modify?(current_user)
      access_denied
      return
    end
    @experiment.destroy

    respond_to do |format|
      format.html { redirect_to(experiments_url) }
      format.xml  { head :ok }
    end
  end
  
   
  def calendars_select_array
   return GoogleCalendar.find(:all, :order => "name")
  end
 
  def locations_select_array
   return Location.find(:all, :order => "building")
  end
end
