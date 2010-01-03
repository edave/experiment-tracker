class HomeController < ApplicationController
  layout 'external'
  def index
    @experiments = Experiment.find(:all, :conditions=>{:open => true})
  end
  
end