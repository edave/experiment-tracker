require 'googlecalendar'
include Googlecalendar
class SubjectsController < ApplicationController
  before_filter :authenticate, {:except => [:new, :update, :create]}

  # GET /subjects
  # GET /subjects.xml
  def index
    @subjects = Subject.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subjects }
    end
  end

  # GET /subjects/1
  # GET /subjects/1.xml
  def show
    @subject = Subject.find_by_hashed_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subject }
    end
  end

  # GET /subjects/new
  # GET /subjects/new.xml
  def new
    @subject = Subject.new
    @slots = Slot.find(:all, :conditions => {:subject_id => nil})
    @slot_id = params[:slot_id]
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subject }
    end
  end

  # GET /subjects/1/edit
  def edit
    @subject = Subject.find_by_hashed_id(params[:id])
  end
  
  def confirmation
     @subject = Subject.find_by_hashed_id(params[:id])
     unless @subject.nil?
      @slot = @subject.slot
     end
  end

  # POST /subjects
  # POST /subjects.xml
  def create
    @subject = Subject.new(params[:subject])
    @slots = Slot.find(:all, :conditions => {:subject_id => nil})
    @slot_id = params[:slot_id]
    @slot = Slot.find_by_hashed_id(@slot_id)
    respond_to do |format|
      if @subject.valid? and !@slot.nil? and @slot.subject.nil? and @subject.save
        @slot.subject = @subject
        @slot.save
        SubjectNotifier.deliver_confirmation(@subject)
        #endtime = @slot.time + 75.minutes
        #g = GData.new
#g.login('dpitmantest@gmail.com', 'halhalhal')
#event = { :title     => 'Experiment - ' + @subject.name,
#          :content   => 'Experiment',
#          :author    => 'Experiment Bot',
#          :email     => 'dpitmantest@gmail.com',
#          :where     => 'Bldg 41',
#          :startTime => @slot.time.strftime("%Y-%m-%dT%H:%M.000Z"),
#          :endTime   => endtime.strftime("%Y-%m-%dT%H:%M.000Z")}
 #         gCal = GCalendar.new('UROP Availability', 'http://www.google.com/calendar/feeds/a56sno2hfu6li22sq9qhoccgjc%40group.calendar.google.com/private-b2d020bec6cc41d5865a89fd2c8cbe1a/basic')
 #         #gCal.url = 'http://www.google.com/calendar/feeds/a56sno2hfu6li22sq9qhoccgjc%40group.calendar.google.com/private-b2d020bec6cc41d5865a89fd2c8cbe1a/basic'
#g.new_event(event, 'UROP Availability')

        
        #flash[:notice] = 'Subject was successfully created.'
        format.html { redirect_to(:action => :confirmation, :id=>@subject.hashed_id) }
        format.xml  { render :xml => @subject, :status => :created, :location => @subject }
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
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to(subjects_url) }
      format.xml  { head :ok }
    end
  end
end
