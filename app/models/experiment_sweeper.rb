 class ExperimentSweeper < ActionController::Caching::Sweeper
    observe Experiment, Slot

    def after_save(record)
      expire_cache(record)
    end
    
    def after_destroy(record)
      expire_cache(record)
    end
    
    def expire_cache(record)
      
      experiment = record.is_a?(Experiment) ? record : record.experiment
      # Pages
      expire_page(:controller => "home", :action => "index")
      
      # Action
      expire_action(:controller => "experiments", :action => %w( show participate ), :id => experiment.hashed_id)
      expire_action(:controller => "subjects", :action => "new", :id => experiment.hashed_id)
      expire_action(:controller => "experiments", :action => "index")
    
    end
  end
