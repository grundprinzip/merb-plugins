require 'rubygems'
require 'spec'            

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

Spec::Runner.configure do |config|
  #config.include Merb::Test::Helper
  #config.include Merb::Test::RspecMatchers
  config.include Merb::Test::RequestHelper  
end

Merb.start :environment => 'test', :session_store => "memory"