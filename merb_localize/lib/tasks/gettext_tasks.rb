require 'gettext/utils'

# Tell ruby-gettext's ErbParser to parse .erb files as well
# See also http://zargony.com/2007/07/29/using-ruby-gettext-with-edge-rails/
GetText::ErbParser.init(:extnames => ['.rhtml', '.erb'])

namespace :gettext do

  desc "Update app pot/po files."
  task :updatepo do #=> :environment do
    name = GettextLocalize::app_name
    version = GettextLocalize::app_name_version
    GetText.update_pofiles(name, Dir.glob("{app,lib,bin}/**/*.{rb,rhtml,erb,rjs}"), version)
  end

  desc "Create app mo files"
  task :makemo do #=> :environment do
    GetText.create_mofiles(true, "po", "locale")
  end
end
