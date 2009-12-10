class SubjectNotifier < ActionMailer::Base
  
  def confirmation(subject)
    setup_email(subject)
    layout 'default'
    css 'default'
    @subject    += ' confirmation'
  end

 
  protected
    def setup_email(subject)
      @recipients  = "#{subject.email}"
      @from        = "noreply@halab-experiments.mit.edu"
      @subject     = "HALab Study :: "
      @sent_on     = Time.now
      @body[:participant] = subject
      @body[:slot] = subject.slot
      content_type "text/html"

      layout 'default'
      css 'default'
    end
end
