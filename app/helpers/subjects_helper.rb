module SubjectsHelper
  
  def add_to_google_calendar(experiment, slot)
    name = CGI::escape(experiment.name + ' Experiment')
    start_time = CGI::escape(@slot.time.utc.strftime("%Y%m%dT%H%M%SZ"))
    end_time = CGI::escape((@slot.time + @experiment.time_length.minutes).utc.strftime("%Y%m%dT%H%M%SZ"))
    location = CGI::escape(@experiment.location.human_location + ", MIT")
    details = CGI::escape("Location: #{ @experiment.location.human_location } - #{ @experiment.location.url }\n" + \
    @experiment.location.directions + "\n\n" + \
    "Please contact #{ @experiment.user.name } at #{ @experiment.user.email } or #{ number_to_phone(@experiment.user.phone) } if you have any questions.")
    return "<a style='float:right;clear:left;' href=\"http://www.google.com/calendar/event?action=TEMPLATE&text=#{name}&dates=#{start_time}/#{end_time}&details=#{details}&location=#{location}&trp=true&sprop=halab-experiments.mit.edu&sprop=name:Experiment%20Signup\" target=\"_blank\"><img src='http://www.google.com/calendar/images/ext/gc_button2.gif' border=0></a>"
  end
end
