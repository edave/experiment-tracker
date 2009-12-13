# "Ascertain" the revision we're running (so named so it'll come before
# the cache initializer, which uses this info).
 
def determine_revision
# Note the revision number we're running, and a
# more-informative string containing it.
revision_path = File.dirname(__FILE__) + "/../../REVISION"
begin
digits = 8
if File.exist? revision_path
mod_date = File.mtime(revision_path)
number = File.read(revision_path).strip[0...digits]
extra = mod_date.strftime("%H:%M %a, %b %d %Y").gsub(" 0"," ")
else
if File.exist?(".git")
number = `git log -1`.split(" ")[1][0...digits]
extra = `git branch`.split("\n").grep(/^\*/)[0].split(' ')[-1]
else
# We don't use --xml anymore, because CentOS's svn doesn't have it.
number = `svn info`.grep(%r"^Revision: ")[0].split(" ")[1]
extra = ''
end
end
rescue
number = '???'
extra = ''
end
details = "#{Rails.env} #{number} #{extra}"
return number, details
end
 
SOURCE_REVISION_NUMBER, SOURCE_REVISION_DETAILS = determine_revision
 
# Add this to the environment too, so it'll be visible in Hoptoad
ENV["SOURCE_REVISION_DETAILS"] = SOURCE_REVISION_DETAILS