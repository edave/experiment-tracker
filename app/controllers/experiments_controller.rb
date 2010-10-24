class ExperimentsController < ApplicationController
  #before_filter :authenticate_user!
  #load_and_authorize_resource :find_by => :obfuscated_query
  cache_sweeper :experiment_sweeper, :only => [ :index, :show, :participate ]


  
  # GET /experiments
  # GET /experiments.xml
  def index
    @experiments = Experiment.where(:user_id => current_user.id)
    page_group(current_user.group)
    page_title("Experiments")
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @experiments }
    end
  end
  
  def admin
    @experiments = Experiment.order('id DESC')
    page_title(["Admin", "Experiments"])
    respond_to do |format|
      format.html
    end
  end

  # GET /experiments/1
  # GET /experiments/1.xml
  def show
    @experiment = Experiment.obfuscated_query(params[:id]).includes(:slots).first
    page_group(@experiment.user.group)
    
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
    @experiment = Experiment.obfuscated(params[:id])
    page_group(@experiment.user.group)
    
    page_title(@experiment.name + " is full")
    
    render :layout => 'external'
  end
  
  def participate
    @experiment = Experiment.obfuscated(params[:id])
    page_group(@experiment.user.group)
    
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
    page_group(current_user.group)
    
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
    @experiment = Experiment.obfuscated(params[:id])
    page_group(@experiment.user.group)
    
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
    page_group(@experiment.user.group)
    
    location = Location.obfuscated(params[:location_id])
    @experiment.location = location
    calendar = GoogleCalendar.obfuscated(params[:calendar_id])
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
    @experiment = Experiment.obfuscated(params[:id])
    page_group(@experiment.user.group)
    
    if @experiment.nil? or !@experiment.can_modify?(current_user)
      access_denied
      return
    end
    location = Location.obfuscated(params[:location_id])
    @experiment.location = location
    calendar = GoogleCalendar.obfuscated(params[:calendar_id])
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
    @experiment = Experiment.obfuscated(params[:id])
    page_group(@experiment.user.group)
    
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
   return GoogleCalendar.order("name")
  end
 
  def locations_select_array
   return Location.order("building")
  end
end
