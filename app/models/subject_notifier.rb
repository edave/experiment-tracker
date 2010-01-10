class SubjectNotifier < ActionMailer::Base
 
  protected
    def setup_email(subject)
      @recipients  = "#{subject.email}"
      @from        = "noreply@halab-experiments.mit.edu"
      @subject     = 'HALab Experiments :: '
      @sent_on     = Time.now
      @body[:participant] = subject
      @body[:slot] = subject.slot
      content_type "text/html"

      layout 'default'
      css 'default'
    end
end
