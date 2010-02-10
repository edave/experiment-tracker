class HomeController < ApplicationController
  layout 'external'
  
  caches_page :index
  cache_sweeper :experiment_sweeper, :only => [ :index ]

  
  def index
    @experiments = Experiment.find(:all, :conditions=>{:open => true})
  end
  
end