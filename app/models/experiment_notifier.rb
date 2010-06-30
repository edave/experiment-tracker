class ExperimentNotifier < ActionMailer::Base
  layout 'mailers/default'
  def schedule(experiment)
    setup_email(experiment)
    day = Date.tomorrow
    @subject    += "#{experiment.name} - #{day.strftime("%m/%e")} Schedule"
    @body[:slots] = experiment.occupied?(day)
    @body[:schedule_date] = day.strftime("%m/%e")
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
