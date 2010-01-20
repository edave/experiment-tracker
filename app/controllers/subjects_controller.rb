class SubjectsController < ApplicationController
  before_filter :login_required, {:except => [:new, :update, :create, :confirmation]}
  #authorize_role [:admin, :experimenter], {:except => [:new, :update, :create, :confirmation]}
  #authorize_role :admin, {:only => [:index, :destroy]}
  
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
    @experiment = Experiment.find_by_hashed_id(params[:id], :include => :slots)
    unless @experiment.open? or @experiment.can_modify?(current_user)
      access_denied
      return
    end
    page_title([@experiment.name, "Sign up"])
  @slots = Slot.find_by_available(@experiment)
    
    if @experiment.filled? or @slots.empty?
      redirect_to :controller=>'experiments', :action=>'filled', :id=>@experiment.hashed_id
      return
    end
    @subject = Subject.new
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
     @slot = Slot.find_by_hashed_id(params[:slot_id])
     unless @subject.nil? or @slot.nil?
      @experiment = @slot.experiment
      page_title([@experiment.name, "Confirmation"])
    else
      page_title("Confirmation not found")
    end
  end
  
  def dummy_confirmation
    @experiment = Experiment.find_by_hashed_id(params[:id])
    unless @experiment != nil and @experiment.can_modify?(current_user)
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
    unless @experiment.open? or @experiment.can_modify?(current_user)
      access_denied
      return
    end
    if @experiment.filled?
      redirect_to :controller=>'experiments', :action=>'filled', :id=>@experiment.hashed_id
      return
    end
    existing_subject = Subject.find_by_email(params[:subject][:email])
    if existing_subject
      @subject = existing_subject
    else
      @subject = Subject.new(params[:subject])
    end
    @slots = Slot.find_by_available(@experiment)
    @slot_id = params[:slot_id]
    @slot = Slot.find_by_hashed_id(@slot_id)
    respond_to do |format|
      begin
      if @subject.valid? and !@slot.nil? and !@slot.filled?
        @subject.transaction do
          @appointment = Appointment.new(:slot => @slot, :subject => @subject)
          @appointment.transaction do
            @subject.save!
            @appointment.save!
             #flash[:notice] = 'Subject was successfully created.'
          format.html { redirect_to(:action => :confirmation, :id=>@subject.hashed_id, :slot_id => @slot.hashed_id) }
          end
       end
      else
        @subject = Subject.new(params[:subject]) #hack to hide existing subject's info
        if @slot == nil
          @subject.errors.add(:time_slot, "Please select a time slot to participate in the experiment")
        elsif @slot.filled?
          @subject.errors.add(:time_slot, "The time you selected is now full, please select another")
        end
        format.html { render :action => "new" }
      end
    rescue ActiveRecord::RecordInvalid
        if !@appointment != nil and !@appointment.valid?
           @subject.errors.add(:appointment, " could not be scheduled, did you already sign up for this?")
        end
        format.html { render :action => "new" }
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
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to(subjects_url) }
      format.xml  { head :ok }
    end
  end
end
