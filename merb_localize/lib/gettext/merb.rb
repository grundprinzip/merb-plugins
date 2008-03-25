=begin
  gettext/rails.rb - GetText for "Ruby on Rails"

  Copyright (C) 2005-2008  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: rails.rb,v 1.72 2008/01/29 16:30:29 mutoh Exp $
=end

require 'gettext/cgi'

module GetText             
  
  # GetText::Merb supports Merb.
  # You add only 2 lines in your controller, all of the controller/view/models are
  # targeted the textdomain. 
  #
  # See <Ruby-GetText-Package HOWTO for Ruby on Rails (http://www.yotabanana.com/hiki/ruby-gettext-howto-rails.html>.
  module Merb
    include GetText

    Merb = ::Merb  #:nodoc:

    alias :_bindtextdomain :bindtextdomain #:nodoc:

    def self.included(mod)  #:nodoc:
      mod.extend self
    end

    module_function
    # call-seq:
    # bindtextdomain(domainname, options = {})
    #
    # Bind a textdomain(#{path}/#{locale}/LC_MESSAGES/#{domainname}.mo) to your program. 
    # Notes the textdomain scope becomes all of the controllers/views/models in your app. 
    # This is different from normal GetText.bindtextomain.
    #
    # Usually, you don't call this directly in your rails application.
    # Call init_gettext in ActionController::Base instead.
    #
    # On the other hand, you need to call this in helpers/plugins.
    #
    # * domainname: the textdomain name.
    # * options: options as a Hash.
    #   * :locale - the locale value such as "ja-JP". When the value is nil, 
    #     locale is searched the order by this value > "lang" value of QUERY_STRING > 
    #     params["lang"] > "lang" value of Cookie > HTTP_ACCEPT_LANGUAGE value 
    #     > Default locale(en). 
    #   * :path - the path to the mo-files. Default is "RAIL_ROOT/locale".
    #   * :charset - the charset. Generally UTF-8 is recommanded.
    #     And the charset is set order by "the argument of bindtextdomain" 
    #     > HTTP_ACCEPT_CHARSET > Default charset(UTF-8).
    #
    #
    def bindtextdomain(domainname, options = {})
      options[:path] ||= File.join(Merb.root, "locale")
      _bindtextdomain(domainname, options)
    end

    @@available_locales = nil
    # Returns locales which supported by the application.
    # This function returns an reversed array of the locale strings under RAILS_ROOT/locale/*.
    # It is used for restriction such as caching files.
    def available_locales
      unless (GetText.cached? and @@available_locales)
        @@available_locales = (Dir.glob(File.join(Merb.root, "locale/[a-z]*")).map{|path| File.basename(path)} << "en").uniq.sort.reverse
      end
      @@available_locales
    end

    # Returns a normalized locale which is in available_locales.
    # * locale: a Locale::Object or nil.
    def normalized_locale(locale = nil)
      locale ||= GetText.locale
      (available_locales &
        [locale.to_general, locale.to_s, locale.language, Locale.default.language, "en"].uniq)[0]
    end

  end
end

module Merb #:nodoc:
  class Controller
    
    include GetText::Merb

    @@gettext_domainnames = []
    @@gettext_content_type = nil
    
    #prepend_before_filter :init_gettext
    #TODO make sure this works
    before :init_gettext
    
    after :init_content_type
     
    def init_gettext_main(cgi) #:nodoc:     
      set_locale_all(nil)
    end

    def init_content_type #:nodoc:
      if headers["Content-Type"] and /javascript/ =~ headers["Content-Type"]
        headers["Content-Type"] = "text/javascript; charset=#{GetText.output_charset}"
      elsif ! headers["Content-Type"]
        headers["Content-Type"] = "#{@@gettext_content_type}; charset=#{GetText.output_charset}"
      end
    end

    def call_methods_around_init_gettext(ary)  #:nodoc:
      ary.each do |block|
        if block.kind_of? Symbol
          send(block)
        else
          block.call(self)
        end
      end
    end

    def init_gettext # :nodoc:
      cgi = nil          
                               
      if defined? request.cgi
        cgi = request.send(:cgi)
      end       

      call_methods_around_init_gettext(@@before_init_gettext)
      init_gettext_main(cgi) if @@gettext_domainnames.size > 0
      call_methods_around_init_gettext(@@after_init_gettext)

      if $TESTING
        @@before_init_gettext = []
        @@after_init_gettext = []
      end
    end

    # Append a block which is called before initializing gettext on the each WWW request.
    #
    # (e.g.)
    #   class ApplicationController < ActionController::Base
    #     before_init_gettext{|controller|
    #       cookies = controller.cookies
    #       if (cookies["lang"].nil? or cookies["lang"].empty?)
    #         GetText.locale = "zh_CN"
    #       else
    #         GetText.locale = cookies["lang"]
    #       end
    #     }
    #     init_gettext "myapp"
    #     # ...
    #   end
    @@before_init_gettext = []
    def self.before_init_gettext(*methods, &block)
      @@before_init_gettext += methods
      @@before_init_gettext << block if block_given? 
    end

    # Append a block which is called after initializing gettext on the each WWW request.
    #
    # The GetText.locale is set the locale which bound to the textdomains
    # when gettext is initialized.
    #
    # (e.g.)
    #   class ApplicationController < ActionController::Base
    #     after_init_gettext {|controller|
    #       L10nClass.new(GetText.locale)
    #     }
    #     init_gettext "foo"
    #     # ...
    #   end
    @@after_init_gettext = []
    def self.after_init_gettext(*methods, &block)
      @@after_init_gettext += methods
      @@after_init_gettext << block if block_given? 
    end
    
    # Bind a 'textdomain' to all of the controllers/views/models. Call this instead of GetText.bindtextdomain.
    # * textdomain: the textdomain
    # * options: options as a Hash.
    #   * :charset - the output charset. Default is "UTF-8"
    #   * :content_type - the content type. Default is "text/html"
    #   * :locale_path - the path to locale directory. Default is {RAILS_ROOT}/locale or {plugin root directory}/locale.
    #
    # locale is searched the order by params["lang"] > "lang" value of QUERY_STRING > 
    # "lang" value of Cookie > HTTP_ACCEPT_LANGUAGE value > Default locale(en). 
    # And the charset is set order by "the argument of bindtextdomain" > HTTP_ACCEPT_CHARSET > Default charset(UTF-8).
    #
    # Note: Don't use content_type argument(not in options). 
    # They are remained for backward compatibility.
    #
    # If you want to separate the textdomain each controllers, you need to call this function in the each controllers.
    #
    # app/controller/blog_controller.rb:
    #  require 'gettext/rails'
    #  
    #  class BlogController < ApplicationController
    #    init_gettext "blog"
    #      :
    #      :
    #    end
    def self.init_gettext(domainname, options = {}, content_type = "text/html")
      opt = {:charset => "UTF-8", :content_type => content_type}
      if options.kind_of? String
        # For backward compatibility
        opt.merge!(:charset => options, :content_type => content_type)
      else
        opt.merge!(options)
      end
      GetText.output_charset = opt[:charset]
      @@gettext_content_type = opt[:content_type]
      locale_path = opt[:locale_path]
      unless locale_path
        cal = caller[0]
        if cal =~ /app.controllers/
          locale_path = File.join(cal.split(/app.controllers/)[0] + "locale")
        else
          locale_path = File.join(Merb.root, "locale")
        end
      end

      unless @@gettext_domainnames.find{|i| i[0] == domainname}
        @@gettext_domainnames << [domainname, locale_path] 
      end

      bindtextdomain(domainname, {:path => locale_path})
      if defined? Merb::Controller
        textdomain_to(Merb::Controller, domainname) 
        #textdomain_to(ActiveRecord::Validations, domainname)
      end                
      
      #textdomain_to(ActionView::Base, domainname) if defined? ActionView::Base
      textdomain_to(Merb::GlobalHelper, domainname) if defined? Merb::GlobalHelper
      #textdomain_to(ActionMailer::Base, domainname) if defined? ActionMailer::Base
    end

    # Gets the textdomain name and path of this controller which is set 
    # with init_gettext. *(Since 1.8)*
    # 
    # * Returns: [[textdomainname1, path1], [textdomainname2, path2], ...]
    def self.textdomains
      @@gettext_domainnames
    end
  end
end

module Merb::Template #:nodoc:
  class << self #:nodoc:       
    
    alias template_for_without_locale template_for #:nodoc:
    # This provides to find localized template files such as foo_ja.rhtml, foo_ja_JP.rhtml
    # instead of foo.rhtml. If the file isn't found, foo.rhtml is used.
    def render_file(path, template_stack = [])
      locale = GetText.locale
      [locale.to_general, locale.to_s, locale.language, Locale.default.language].uniq.each do |v|
        localized_path = "#{template_path}_#{v}"
        return template_for_without_locale(localized_path, template_stack) if file_exists? localized_path
      end
      template_for_without_locale(path, template_stack)
    end
    
  end
end


if $TESTING
  GetText.cached = false
end