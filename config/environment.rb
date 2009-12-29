# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

DO_NOT_REPLY = "donotreply@halab-experiments.mit.edu"

ENCRYPTED_ATTR_PASSKEY = "BWzMfbB3VSwbUxuO"

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
   
  # Date selecter UI
  config.gem "calendar_date_select"
  
  # Both are for awesome_emailer plugin
  config.gem 'hpricot', :version => '=0.6.161'
  config.gem 'csspool', :version => '=0.2.6'
  
  # For google calendar
  config.gem 'gcal4ruby'
  
  # For encrypting model attributes
  config.gem 'attr_encrypted', :version => '~> 1.0.8', 
  :lib => 'attr_encrypted', :source => 'http://gems.github.com'
  
  # For background tasks
  config.gem 'rufus-scheduler', :lib => "rufus/scheduler"
  
  # For Markdown text processing
  config.gem 'bluecloth', :version => '~> 2.0.5', :lib => 'bluecloth'
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Eastern Time (US & Canada)'
  
  # ActiveRecord config
  config.active_record.colorize_logging = true
  #config.active_record.default_timezone = :local
  
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address  => "mail.hci4.me",
    :port  => 587, 
    :domain  => "hci4.me",
    :user_name  => "noreply@hci4.me",
    :password  => "5VQ891zTUI6C",
    :authentication  => :login
      } 
  
end