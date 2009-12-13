# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
    def show_admin_content?
    signed_in_as_admin?
  end
  
  def page_title
    return ' :: ' + @my_page_title.join(' : ') if @my_page_title
  end
  
    def request_forgery_protection_tag
    @request_forgery_protection_tag ||= \
      tag(:input, :type => "hidden", 
          :name => request_forgery_protection_token.to_s, 
          :value => form_authenticity_token,
          :id => 'authenticity_token') \
      if protect_against_forgery?
  end
end
