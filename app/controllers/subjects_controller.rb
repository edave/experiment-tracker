class SubjectsController < ApplicationController
  before_filter :login_required, {:except => [:new, :update, :create, :confirmation]}
  authorize_role [:admin, :experimenter], {:except => [:new, :update, :create, :confirmation]}
  
  layout 'external'
  
  # GET /subjects
  # GET /subjects.xml
  def index
    @subjects = Subject.all
    page_title("Subjects")
    
    respond_to do |format|
      format.html { render :layout => 'application' }
    end
  end

  # GET /subjects/1
  # GET /subjects/1.xml
  def show
    @subject = Subject.find_by_hashed_id(params[:id])
    page_title(["Subject", @subject.name])
    respond_to do |format|
      format.html { render :layout => 'application' }
    end
  end

  # GET /subjects/new
  # GET /subjects/new.xml
  def new
    @experiment = Experiment.find_by_hashed_id(params[:id])
    unless !@experiment.open? and @experiment.can_modify?(current_user)
      access_denied
      return
    end
    page_title([@experiment.name, "Sign up"])
    if Slot.find_by_occupied(@experiment).length >= @experiment.num_subjects
      redirect_to :controller=>'experiments', :action=>'filled', :id=>@experiment.hashed_id
      return
    end
    @subject = Subject.new
    @slots = Slot.find_by_available(@experiment)
    @slot_id = params[:slot_id]
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subject }
    end
  end

  # GET /subjects/1/edit
  def edit
    @subject = Subject.find_by_hashed_id(params[:id])
    page_title(["Edit Subject", @subject.name])
    render :layout => 'application'
  end
  
  def confirmation
     @subject = Subject.find_by_hashed_id(params[:id])
     unless @subject.nil?
      @slot = @subject.slot
      @experiment = @slot.experiment
      page_title([@experiment.name, "Confirmation"])
     end
  end
  
  def dummy_confirmation
    @experiment = Experiment.find_by_hashed_id(params[:id])
    unless @experiment != nil and @experiment.owned_by?(current_user)
      access_denied
      return
    end
    page_title([@experiment.name, "Example Confirmation"])
    @subject = Subject.new(:name => "Test Subject", :email => "test@example.com")
    @slot = Slot.new(:experiment => @experiment, :time => Time.zone.now)
     
    respond_to do |format|
      format.html {render :action => :confirmation}
    end
  end

  # POST /subjects
  # POST /subjects.xml
  def create
     @experiment = Experiment.find_by_hashed_id(params[:experiment_id])
    unless !@experiment.open? and @experiment.can_modify?(current_user)
      access_denied
      return
    end
    if Slot.find_by_occupied(@experiment).length >= @experiment.num_subjects
      redirect_to :controller=>'experiments', :action=>'filled', :id=>@experiment.hashed_id
      return
    end
    @subject = Subject.new(params[:subject])
    @slots = Slot.find(:all, :conditions => {:subject_id => nil})
    @slot_id = params[:slot_id]
    @slot = Slot.find_by_hashed_id(@slot_id)
    respond_to do |format|
      if @subject.valid? and !@slot.nil? and @slot.subject.nil?
        @subject.transaction do
          @slot.transaction do
            @subject.save
            @slot.subject = @subject
            SlotNotifier.deliver_confirmation(@slot)
            @slot.save
        
        #flash[:notice] = 'Subject was successfully created.'
        format.html { redirect_to(:action => :confirmation, :id=>@subject.hashed_id) }
        format.xml  { render :xml => @subject, :status => :created, :location => @subject }
      end
      end
      else
        
        if @slot == nil
          @subject.errors.add(:time_slot, "Please select a time slot to participate in the experiment")
        end
        format.html { render :action => "new" }
        format.xml  { render :xml => @subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.xml
  def update
    @subject = Subject.find_by_hashed_id(params[:id])
    
    respond_to do |format|
      if @subject.update_attributes(params[:subject])
        flash[:notice] = 'Subject was successfully updated.'
        format.html { redirect_to(@subject) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subject.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.xml
  def destroy
    @subject = Subject.find_by_hashed_id(params[:id])
    #@subject.destroy

    respond_to do |format|
      format.html { redirect_to(subjects_url) }
      format.xml  { head :ok }
    end
  end
end
