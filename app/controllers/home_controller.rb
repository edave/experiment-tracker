class HomeController < ApplicationController
  layout 'external'
  def index
    @experiments = Experiment.find(:all)
  end
  
end