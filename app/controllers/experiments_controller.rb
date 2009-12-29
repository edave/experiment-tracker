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
    @experiment = Experiment.find_by_hashed_id(params[:id])
    unless @experiment.owned_by?(current_user)
      redirect_to :controller=>'experiments', :action=>'list'
      return 
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @experiment }
    end
  end
  
  def filled
    @experiment = Experiment.find_by_hashed_id(params[:id])
    render :layout => 'external'
  end
  
  def participate
    @experiment = Experiment.find_by_hashed_id(params[:id])
    render :layout => 'external'
  end

  # GET /experiments/new
  # GET /experiments/new.xml
  def new
    @experiment = Experiment.new
    self.use_markdown_editor = true
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @experiment }
    end
  end

  # GET /experiments/1/edit
  def edit
    @experiment = Experiment.find_by_hashed_id(params[:id])
    self.use_markdown_editor = true
    unless @experiment.owned_by?(current_user)
      redirect_to :controller=>'experiments', :action=>'list'
      return
    end
  end

  # POST /experiments
  # POST /experiments.xml
  def create
    @experiment = Experiment.new(params[:experiment])
    @experiment.user = current_user
    respond_to do |format|
      if @experiment.save
        flash[:notice] = 'Experiment was successfully created.'
        format.html { redirect_to(:controller => :experiments, :action => :show, :id => @experiment.hashed_id) }
        format.xml  { render :xml => @experiment, :status => :created, :location => @experiment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @experiment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /experiments/1
  # PUT /experiments/1.xml
  def update
    @experiment = Experiment.find_by_hashed_id(params[:id])

    respond_to do |format|
      if @experiment.can_modify?(current_user) and @experiment.update_attributes(params[:experiment])
        flash[:notice] = 'Experiment was successfully updated.'
        format.html { redirect_to(@experiment) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @experiment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /experiments/1
  # DELETE /experiments/1.xml
  def destroy
    @experiment = Experiment.find_by_hashed_id(params[:id])
    @experiment.destroy

    respond_to do |format|
      format.html { redirect_to(experiments_url) }
      format.xml  { head :ok }
    end
  end
end
