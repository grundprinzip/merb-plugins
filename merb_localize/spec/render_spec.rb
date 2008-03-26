require File.join(File.dirname(__FILE__), "spec_helper")
require File.join(File.dirname(__FILE__), "controller", "controllers")

describe RenderController do
                           
  before do
    Merb::Router.prepare do |r|
      r.default_routes
    end
  end

  it "should read the default locale" do
    GettextLocalize.set_locale("en_US")
    GettextLocalize.locale.should == "en_US"
    dispatch_to(RenderController, :test)
    
    GettextLocalize.set_locale("ca-es")
    GettextLocalize.locale.should == "ca_ES"
    dispatch_to(RenderController, :test)
  end               
  
  it "should set the default locales for the controller" do
    
    GettextLocalize.default_locale = "ca-es"
    dispatch_to(RenderController, :test).body.should == view_in_cat
                                                                   
    GettextLocalize.default_locale = "en-US"
    dispatch_to(RenderController, :test).body.should == view_in_usa
  end                                                              
  
  it "should overwrite the defaults if set" do
    GettextLocalize.default_locale = "ca-es"
    dispatch_to(RenderControllerBeforeDefaultLocale, :test).body.should == view_in_usa
    
    GettextLocalize.default_locale = "ca"
    dispatch_to(RenderControllerBeforeDefaultCountry, :test).body.should == view_in_cat
  end           
  
  it "should set the locale by all possibilities" do
    GettextLocalize.default_locale = "ca-es"
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => ""
    }).body.should == view_in_cat 
    
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => "en-us"
    }).body.should == view_in_usa
    
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => ""
    }){ |c|
                         
      c.session['l'] = "ca-es"
      
    }.body.should == view_in_cat
    
  end
                    
  
  def view_in_cat
    expect =<<EOF
locale: ca_ES
country: es
currency: 1.000,50 €
string: Gener
EOF
    expect
  end
  
  def view_in_spa
    expect =<<EOF
locale: es_ES
country: es
currency: 1.000,50 €
string: Enero
EOF
    expect
  end
  
  def view_in_usa
    res = <<EOF
locale: en_US
country: us
currency: $1,000.50
string: January
EOF
    res
  end
  
end