if defined?(Merb::Plugins) 
                           
  # check for helper enabled
  config = Merb::Plugins.config[:merb_localize]   
  if config && config[:exclude_helper]
    EXCLUDE_HELPERS = true     
    
    # add the dependency for merb_helpers
    dependency "merb_helpers"
    
  else            
    EXCLUDE_HELPERS = false
  end
  
  # Ruby unicode support
  $KCODE = 'u'
  require 'jcode'
  
  dependency "gettext", '>= 1.9'
  require 'gettext/utils'        
  require File.expand_path(File.dirname(__FILE__) / 'gettext/merb' )
  
  # global methods
  # all in the GettextLocalize module
 require File.expand_path(File.dirname(__FILE__) /  'gettext_localize/gettext_localize')

  # locale used in the literals to be translated
  GettextLocalize::original_locale = 'en'
  # locale in case everything else fails
  GettextLocalize::fallback_locale = 'ca'
  # country if everything else fails
  GettextLocalize::fallback_country = 'es'

  # initialize country options from YML file
  GettextLocalize::set_country_options

  # base ruby class extensions
  require File.expand_path(File.dirname(__FILE__) /  'gettext_localize/gettext_localize_extend')
  require File.expand_path(File.dirname(__FILE__) /  'gettext_localize/gettext_localize_merb')

  # set paths with LC_MESSAGES    
  GettextLocalize::set_locale_paths
  
  # Register the extension to Merb::Controller
  Merb::Controller.__send__(:include, GettextLocalize::Controller)
                          
  # Register the default before filter for a merb controller
  class Merb::Controller
    before Proc.new {|c|    
      c.set_default_gettext_locale
    }
  end
  
  Merb::Plugins.add_rakefiles(File.join(File.dirname(__FILE__) / "tasks" / "gettext_tasks" ))
end
