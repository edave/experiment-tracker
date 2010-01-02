default_run_options[:pty] = true
set :application, "experiment-signup"
set :repository,  "git@github.com:edave/experiment-tracker.git"

set :scm, :git
set :scm_passphrase, ""
set :user, "halab"
ssh_options[:forward_agent] = true

set :branch, "master"
set :deploy_via, :remote_cache
set :deploy_to, "/var/www/experiment-signup"
set :git_shallow_clone, 1
set :git_enable_submodules, 1


# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "halab-experiments.mit.edu"                          # Your HTTP server, Apache/etc
role :app, "halab-experiments.mit.edu"                          # This may be the same as your `Web` server
role :db,  "halab-experiments.mit.edu", :primary => true # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

 namespace :deploy do
  task :start, :roles => :app do
    #run "#{sudo} /etc/init.d/nginx start" 
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    #run "#{sudo} /etc/init.d/nginx stop"
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "#{sudo} /etc/init.d/nginx restart" 
    run "touch #{current_release}/tmp/restart.txt"
  end

end

namespace :rooster do
  desc "Reload Rooster Daemon"
  task :reload, :roles => :rooster do
    rails_env = fetch(:rails_env, "production")
    run "cd #{current_path} && sudo rake RAILS_ENV=#{rails_env} rooster:reload"
  end
end
