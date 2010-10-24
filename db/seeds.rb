# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

# Setup site-wide roles
admin = Role.new(:name => "Admin", :description => "Overall site admin")
admin.slug = "admin"
admin.save!

experimenter = Role.new(:name => "Experimenter", :description => "Base experimenter")
experimenter.slug = "experiment"
experimenter.save!