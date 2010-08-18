ExperimentTracker::Application.routes.draw do
  devise_for :users

  root :to => "home#index"

  resources :groups
  resources :subjects
  resources :slots do
  
    member do
  get :cancel
  end
  
  end

  resources :experiments do
    collection do
  get :admin
  end
  
  
  end

  resources :privileges
  resources :locations
  resources :google_calendars
  resources :preview do
  
    member do
  post :markdown
  end
  
  end 

 match '/:controller(/:action(/:id))'
end
