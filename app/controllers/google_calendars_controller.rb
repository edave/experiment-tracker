class GoogleCalendarsController < ApplicationController
  
  # GET /google_calendars
  # GET /google_calendars.xml
  def index
    @google_calendars = GoogleCalendar.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @google_calendars }
    end
  end

  # GET /google_calendars/1
  # GET /google_calendars/1.xml
  def show
    @google_calendar = GoogleCalendar.find_by_hashed_id(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @google_calendar }
    end
  end

  # GET /google_calendars/new
  # GET /google_calendars/new.xml
  def new
    @google_calendar = GoogleCalendar.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @google_calendar }
    end
  end

  # GET /google_calendars/1/edit
  def edit
    @google_calendar = GoogleCalendar.find_by_hashed_id(params[:id])
  end

  # POST /google_calendars
  # POST /google_calendars.xml
  def create
    @google_calendar = GoogleCalendar.new(params[:google_calendar])

    respond_to do |format|
      if @google_calendar.save
        flash[:notice] = 'GoogleCalendar was successfully created.'
        format.html { redirect_to(@google_calendar) }
        format.xml  { render :xml => @google_calendar, :status => :created, :location => @google_calendar }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @google_calendar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /google_calendars/1
  # PUT /google_calendars/1.xml
  def update
    @google_calendar = GoogleCalendar.find_by_hashed_id(params[:id])

    respond_to do |format|
      if @google_calendar.update_attributes(params[:google_calendar])
        flash[:notice] = 'GoogleCalendar was successfully updated.'
        format.html { redirect_to(@google_calendar) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @google_calendar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /google_calendars/1
  # DELETE /google_calendars/1.xml
  def destroy
    @google_calendar = GoogleCalendar.find_by_hashed_id(params[:id])
    @google_calendar.destroy

    respond_to do |format|
      format.html { redirect_to(google_calendars_url) }
      format.xml  { head :ok }
    end
  end
  
  def get_calendars
    @google_calendars = GoogleCalendar.calendars(params[:login], params[:password])
    
    respond_to do |format|
      format.json {render :json => @google_calendars.to_json()}
    end
  end
end
