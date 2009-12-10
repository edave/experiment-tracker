default_run_options[:pty] = true
set :application, "experiment"
set :repository,  "git@github:edavepitman/experimenter.git"

set :scm, :git
set :scm_passphrase, "hal2001"
set :user, "halab"
ssh_options[:forward_agent] = true

set :branch, "master"
set :deploy_via, :remote_cache
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
   task :start {}
   task :stop {}
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end