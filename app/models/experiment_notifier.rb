class ExperimentNotifier < ActionMailer::Base
  default :from => "noreply@halab-experiments.mit.edu"
  layout 'mailers/default'
  def schedule(experiment, day = Date.tomorrow)
    @subject    = "#{experiment.name} Upcoming Schedule"
    @slots = experiment.occupied_slots(day)
    @schedule_date = day.strftime("%B %e (%a)")
    setup_email(experiment)
  end
 
  protected
    def setup_email(experiment)
      @experiment = experiment
      
      mail(:to => "#{experiment.user.email}",
           :subject => experiment.name + ' :: ' + @subject)

      css 'email'
    end
end
