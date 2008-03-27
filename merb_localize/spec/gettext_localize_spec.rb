require File.join(File.dirname(__FILE__), "spec_helper")
require File.join(File.dirname(__FILE__), "controller", "controllers")
         
APP_NAME = ""
APP_VERSION = ""

describe GettextLocalize do
   
  before do         
    
    GettextLocalize.set_locale(nil)
    GettextLocalize.set_country(nil)
    
    Merb::Router.prepare do |r|
      r.default_routes
    end
  end
  
  it "should set and get the textdomain" do
    GettextLocalize.textdomain
    GettextLocalize.default_textdomain = 'gettext_localize'
    
    GettextLocalize.textdomain.should == "gettext_localize"
  end
  
  it "should set and get the application name and version and look for default" do
    app_dir = Pathname.new(Merb.root).realpath.basename.to_s
    
    GettextLocalize.app_name.should == app_dir

    GettextLocalize.app_name = 'app'
    GettextLocalize.app_name.should == "app"

    GettextLocalize.app_name_version.should == "app 1.0.0"
    
    GettextLocalize.app_version = '3.2.5'
    GettextLocalize.app_version.should == "3.2.5"         
    GettextLocalize.app_name_version.should == "app 3.2.5"
    
    APP_NAME.replace 'new_app'
    GettextLocalize.app_name.should == "new_app"          
    GettextLocalize.app_name_version.should == "new_app 3.2.5"
    
    APP_VERSION.replace '4.3.1'                               
    GettextLocalize.app_name_version.should == "new_app 4.3.1"
    
  end
  
  it "should get and set country information" do
    GettextLocalize.set_locale(nil)
    GettextLocalize.default_locale = ''
    GettextLocalize.fallback_locale = ''
    ENV['LANG'] = ''
    GettextLocalize.fallback_country = 'us'
    
    GettextLocalize.country.should == "us"
    
    GettextLocalize.default_country = 'es'
    GettextLocalize.country.should == "es"
    
    ENV['LANG'] = 'en_US'
    GettextLocalize.country.should == "us"
    
    GettextLocalize.default_locale = 'ca_ES'
    GettextLocalize.country.should == "es"
    
    GettextLocalize.set_country('us')     
    GettextLocalize.country.should == "us"
  end
  
  it "should get and set locale data" do
    GettextLocalize.default_locale = ''
    ENV['LANG'] = ''
    GettextLocalize.fallback_locale = 'ca-es'
    
    GettextLocalize.locale.should == "ca_ES"
    ENV['LANG'] = 'es_ES@euro'
    GettextLocalize.locale.should == "es_ES"
    
    GettextLocalize.default_locale = 'en_US'
    GettextLocalize.locale.should == "en_US"

    GettextLocalize.set_country('es')
    GettextLocalize.set_locale('ca')
    GettextLocalize.locale.should == "ca_ES"
  end
                  
  it "should survive to wrong country options" do
    options = GettextLocalize.get_country_options
    GettextLocalize.set_country_options(nil)
    GettextLocalize.set_country_options('ñaña')
    
    GettextLocalize.get_country_options.should == options
    
    GettextLocalize.send(:class_variable_set,:@@country_options,nil)
    GettextLocalize.set_country_options('ñaña').should be_false
    GettextLocalize.set_country_options('ñaña').should be_false        
    
    Date.new(2006,12,1).strftime("%d-%m-%Y").should == "01-12-2006"
    Time.mktime(2006,12,1).strftime("%d-%m-%Y").should == "01-12-2006"
  end

  it "should set and get the dispatch options" do
    GettextLocalize.default_methods = nil
    GettextLocalize.methods.should == []     
    
    GettextLocalize.default_methods = "param"
    GettextLocalize.methods.should == ["param"]
                                                        
    GettextLocalize.default_methods = [:param, :session]
    GettextLocalize.methods.should == [:param, :session]
  end
     
  it "should survive bad entries" do
    methods = GettextLocalize.send(:class_variable_get,:@@methods).dup
    GettextLocalize.send(:class_variable_set,:@@methods,nil)
    
    GettextLocalize.methods.should == []                        
    
    GettextLocalize.send(:class_variable_set,:@@methods,methods)
    expect = Pathname.new(File.join(Merb.root,'locale')).realpath.to_s
    
    GettextLocalize.send(:get_locale_path,'.').should == expect
    
    GettextLocalize.send(:get_locale_path,'lopu').nil?.should be_true
  end

  it "should show available locales" do
    all = GettextLocalize.all_locales
    supported = GettextLocalize.supported_locales
    supported.each do |lc|                       
      all[lc].should == supported[lc]
    end
  end
end