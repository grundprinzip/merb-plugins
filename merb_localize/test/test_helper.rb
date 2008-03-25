require 'rubygems'
require 'test/unit'            

require 'merb-core'
require 'merb-core/core_ext/class'   
require 'merb-core/test'
require 'merb-core/test/helpers'

$TESTING=true 
#$DEBUG = true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')


require 'merb_localize'                            
    
# Set the textdomain                  
GetText::bindtextdomain("gettext_localize",:path=>GettextLocalize::get_locale_path)                  

class Test::Unit::TestCase           
  include Merb::Test::Helpers
  include Merb::Test::RequestHelper
end
