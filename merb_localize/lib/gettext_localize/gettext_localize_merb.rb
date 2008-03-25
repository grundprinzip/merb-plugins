module GettextLocalize
     
  # Extension for Merb::Controller
  module Controller            
       
    # loads default gettext in every controller
    # can be overriden in a controller by
    # calling init_gettext
    def init_default_gettext(textdomain=nil)
      textdomain = GettextLocalize::textdomain if textdomain.nil?
      unless textdomain.nil?
        Merb::Controller::init_gettext(textdomain)
        true
      end
    end

    # loads default locale in every controller
    # can be overriden by calling set_locale
    def set_default_locale(locale=nil)
      locale = GettextLocalize::locale if (locale.nil? || locale == 'en-us') # FIXME Hack for Rails 2.0
      unless locale.nil?
        GettextLocalize::set_locale(locale)
        true
      end
    end

    # sets locale unless nil or empty
    def set_locale_if(locale=nil)
      locale = locale.respond_to?(:to_s) ? locale.to_s : ""
      set_default_locale locale unless locale.strip.empty?
    end

    # binds default textdomain in every controller
    # can be overriden by calling bindtextdomain
    def bind_default_textdomain(textdomain=nil)
      textdomain = GettextLocalize::textdomain if textdomain.nil?
      textdomain = Merb::Controller.textdomainname if textdomain.nil?

      unless textdomain.nil?
        GetText::bindtextdomain(textdomain,:path=>GettextLocalize::get_locale_path)
        true
      end
    end

    # sets a controllers country
    # by default uses GettextLocalize::default_country
    def set_country(country)
      unless country.nil?
        GettextLocalize::set_country(country)
        true
      end
    end
    alias :set_default_country :set_country

    # by default sets locale, textdomain and gettext in all controllers
    # forces default locale if nothing found, not set when executing
    # set_locale_by directly
    def set_default_gettext_locale(locale=nil,textdomain=nil,methods=nil)
      methods = GettextLocalize::methods if methods.nil?
      methods << :default
      set_locale_by(*methods)
      bind_default_textdomain(textdomain)
      init_default_gettext(textdomain)
    end

    # sets controllers locale by the methods specified
    # tries them in order till one works
    # available methods = :header, :cookie, :session, :param
    # example use in controller class, calling before_filter with params:
    # <tt>before_filter(:except=>"feed"){|c| c.set_locale_by :param, :session, :header }</tt>
    def set_locale_by(*methods)
      params = []
      if methods.first.kind_of? Array
        params = methods[1..-1]
        methods = methods.first
      end
      methods << :default
      methods.each do |method|
        func = "set_locale_by_#{method}".to_sym
        if respond_to?(func)
          return true if self.send(func,*params) == true
        end
      end
    end

    # sets the controllers locale by the user header
    # tries to find the language localizations starting
    # from the best language
    # example header:
    # <tt>HTTP_ACCEPT_LANGUAGE = es-es,es;q=0.8,en-us;q=0.5,en;q=0.3</tt>
    # add to your controller:
    # <tt>before_filter :set_locale_by_header</tt>
    def set_locale_by_header(name='lang')
      name = 'HTTP_ACCEPT_LANGUAGE'
      GettextLocalize::set_locale(nil)
      locales = self.get_locales_from_hash(request.env,name)
      return unless locales
      locales.each do |locale|
        if GettextLocalize.has_locale?(locale)
          return set_default_locale(locale)
        end
      end
    end

    # sets the controllers locale by the content of a cookie
    # by default takes the cookie named 'lang'
    # tries to find the language localizations starting from
    # the first language specified, separated by commas, example
    # <tt> cookies['lang'] = 'es-es,es,en,en-us'</tt>
    # add to your controller:
    # <tt>before_filter :set_locale_by_cookie</tt>
    def set_locale_by_cookie(name="lang")
      GettextLocalize::set_locale(nil)
      locales = self.get_locales_from_hash(cookies,name)
      return unless locales
      locales.each do |locale|
        if GettextLocalize.has_locale?(locale)
          return set_default_locale(locale)
        end
      end
    end

    # sets the controllers locale by the content of a cookie
    # by default takes the cookie named 'lang'
    # tries to find the language localizations starting from
    # the first language specified, separated by commas, example
    # <tt> session['lang'] = 'es,fr'</tt>
    # add to your controller:
    # <tt>before_filter :set_locale_by_session</tt>
    # remember this only saves the session lang if
    # use session is activated
    def set_locale_by_session(name='lang')
      GettextLocalize::set_locale(nil)
      locales = self.get_locales_from_hash(session,name)
      return unless locales
      locales.each do |locale|
        # has_locale? checks if locale file exists
        # FIXME: could return false if locale file
        # outside of the application
        if GettextLocalize.has_locale?(locale)
          return set_default_locale(locale)
        end
      end
    end

    # sets the controllers locale by the value of a param
    # passed by GET or POST, by default named 'lang'
    # with values of locales separated by commas,
    # tries to find them in order, for example calling
    # the url <tt>http://localhost:3000/?lang=es</tt>
    # and in the controller:
    # <tt>before_filter :set_locale_by_param</tt>
    def set_locale_by_param(name='lang')
      GettextLocalize::set_locale(nil)
      locales = self.get_locales_from_hash(params,name)
      return unless locales
      locales.each do |locale|
        if GettextLocalize.has_locale?(locale)
          return set_default_locale(locale)
        end
      end
    end

    # sets the default locale
    # used to define <tt>set_locale_by :param, :default</tt>
    def set_locale_by_default(name='lang')
      set_default_locale
    end

    protected

    # reads a locales parameter from a hash
    # accepts header format with priorities (see set_locale_by_header)
    # and a list of locales separated by commas
    def get_locales_from_hash(hash,name='lang')
      name = name.to_sym if hash[name.to_sym]
      name = name.to_s if hash[name].respond_to?(:empty?) and hash[name].empty?
      return unless hash[name]
      value = hash[name].dup
      return unless value.respond_to?(:to_s)
      value = value.to_s.strip
      return if value.empty?

      if value.include?("q=") # format with priorities
        locales = {}
        value.scan(/([^;]+);q=([^,]+),?/).each do |langs,priority|
          locales[priority.to_f] = langs.split(",")
        end
        locales = locales.sort.reverse.map{|p| p.last }.flatten
      else # format separated commas
        locales = []
        locales = value.split(",")
      end
      return locales
    end
  end
  
end