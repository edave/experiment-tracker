class ExperimentNotifier < ActionMailer::Base
  
  def schedule(experiment)
    setup_email(experiment)
    day = Date.tomorrow
    @subject    += "#{experiment.name} - #{day.strftime("%m/%e")} Schedule"
    @body[:slots] = experiment.occupied_slots(day)
    @body[:schedule_date] = day.strftime("%m/%e")
  end
 
  protected
    def setup_email(experiment)
      @recipients  = "#{experiment.user.email}"
      @from        = "noreply@halab-experiments.mit.edu"
      @subject     = "HALab Study :: "
      @sent_on     = Time.now
      @body[:experiment] = experiment
      
      content_type "text/html"

      layout 'default'
      css 'default'
    end
end
