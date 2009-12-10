# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Experiment_session',
  :secret      => '5579a6a85ac8d910e9f9d3a086dcc61734297b6a4fc8853a423a1562c0971f9093645cc6a28edb45df38ebecbe5b86bd472f7b685fcc17c282d3a472117ee206'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
