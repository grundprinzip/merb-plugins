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
GettextLocalize.set_default_textdomain("gettext_localize")


class Test::Unit::TestCase           
  include Merb::Test::Helpers
  include Merb::Test::RequestHelper
  include Merb::Test::RouteHelper
end         

Merb.start :environment => "test", :session_store => "memory"
