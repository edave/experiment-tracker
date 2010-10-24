class HomeController < ApplicationController
  layout 'external'

  access_control do
    allow all
  end  
  
  caches_page :index
  cache_sweeper :experiment_sweeper, :only => [ :index ]

  
  def index
    @groups = Group.all
  end
  
end