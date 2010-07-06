class ExperimentNotifier < ActionMailer::Base
  layout 'mailers/default'
  def schedule(experiment, day = Date.tomorrow)
    setup_email(experiment)
    @subject    += "#{experiment.name} Upcoming Schedule"
    @body[:slots] = experiment.occupied_slots(day)
    @body[:schedule_date] = day.strftime("%B %e (%a)")
  end
 
  protected
    def setup_email(experiment)
      @recipients  = "#{experiment.user.email}"
      @from        = "noreply@halab-experiments.mit.edu"
      @subject     = experiment.name + ' :: '
      @sent_on     = Time.now
      @body[:experiment] = experiment
      
      content_type "text/html"

      css 'email'
    end
end
