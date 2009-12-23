class PreviewController < ApplicationController
  
  def markdown
    render :layout => false
  end
end
