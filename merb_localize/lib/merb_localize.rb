if defined?(Merb::Plugins)  
  
  # Ruby unicode support
  $KCODE = 'u'
  require 'jcode'
  
  dependency "gettext", '>= 1.9'
  require 'gettext/utils'
  
  # global methods
  # all in the GettextLocalize module
  require 'gettext_localize/gettext_localize'

  # locale used in the literals to be translated
  GettextLocalize::original_locale = 'en'
  # locale in case everything else fails
  GettextLocalize::fallback_locale = 'ca'
  # country if everything else fails
  GettextLocalize::fallback_country = 'es'

  # initialize country options from YML file
  GettextLocalize::set_country_options

  # base ruby class extensions
  require 'gettext_localize/gettext_localize_extend'

  # set paths with LC_MESSAGES
  #GettextLocalize::set_locale_paths

  
  Merb::Plugins.add_rakefiles(File.join(File.dirname(__FILE__) / "tasks" / "gettext_tasks" ))
end
