class HomeController < ApplicationController
  layout 'external'
  
  caches_page :index
  cache_sweeper :experiment_sweeper, :only => [ :index ]

  
  def index
    @groups = Group.find(:all)
  end
  
end