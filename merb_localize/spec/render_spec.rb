require File.join(File.dirname(__FILE__), "spec_helper")
require File.join(File.dirname(__FILE__), "controller", "controllers")

describe RenderController do
                           
  before do         
    
    GettextLocalize.set_locale(nil)
    GettextLocalize.set_country(nil)
    
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
      c.cookies['l'] = "ca-es"
    }.body.should == view_in_cat
    
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => ""
    }){ |c|
      c.params['l'] = "en-us"
    }.body.should == view_in_usa
    
    #TODO add session test
    
  end      
  
  it "should set the locale by header" do
    GettextLocalize.default_locale = "ca-es"
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => ""
    }).body.should == view_in_cat
    
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => "en-us"
    }).body.should == view_in_usa
    
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => 'es-es,es;q=0.8,en-us;q=0.5,en;q=0.3'
    }).body.should == view_in_spa
    
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => 'lo-la,li;q=0.8,en-us;q=0.5,en;q=0.3'
    }).body.should == view_in_usa
    
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => 'la-lo,lu,es-es'
    }).body.should == view_in_spa
  end
                                
  it "should not memeorize the locale by param" do
    GettextLocalize.default_locale = "ca-es"
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => ""
    }){ |c|
      c.params['l'] = "en-us"
    }.body.should == view_in_usa
    
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => ""
    }){ |c|
      c.params['l'] = ""
    }.body.should == view_in_cat
    
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => ""
    }){ |c|
      c.params['l'] = "es"
    }.body.should == view_in_spa
    
    dispatch_to(RenderControllerByEverything, :test, {}, {
      "HTTP_ACCEPT_LANGUAGE"  => ""
    }){ |c|
      c.params['l'] = ""
    }.body.should == view_in_cat
  end             
  
  it "should not meoryize the locale by cookie" do                                                 
     GettextLocalize.default_locale = "ca-es"                                                      
     locale_dispatch(RenderControllerByEverything, :test).body.should == view_in_cat
     locale_dispatch(RenderControllerByEverything, :test, nil, nil, "en-us").body.should == view_in_usa
     locale_dispatch(RenderControllerByEverything, :test).body.should == view_in_cat
  end                         
  
  it "should find symbols and string in cookies" do
    GettextLocalize.default_locale = "ca-es"
     locale_dispatch(RenderControllerByEverything, :test).body.should == view_in_cat
     locale_dispatch(RenderControllerByEverything, :test, nil, nil, "en-us").body.should == view_in_usa
     
     dispatch_to(RenderControllerByEverything, :test, {}, {
       "HTTP_ACCEPT_LANGUAGE"  => ""
     }){ |c|
       c.cookies[:l] = "es"
     }.body.should == view_in_spa
     
     dispatch_to(RenderControllerByEverything, :test, {}, {
        "HTTP_ACCEPT_LANGUAGE"  => ""
      }){ |c|
        c.cookies[:l] = ""
      }.body.should == view_in_cat
      
      locale_dispatch(RenderControllerByEverything, :test, nil, nil, "es").body.should == view_in_spa
  end    
  
  it "should be param agnostic to strings and symbols" do
    GettextLocalize.default_locale = "ca-es"
    locale_dispatch(RenderControllerByEverything, :test).body.should == view_in_cat
    
     dispatch_to(RenderControllerByEverything, :test, {:l => "en-us"}, {
       "HTTP_ACCEPT_LANGUAGE"  => ""
     }).body.should == view_in_usa
  end
  
           
  def locale_dispatch(controller, action, locale_param = nil, locale_http = nil, cookie=nil)
    dispatch_to(controller, action, {"l" => locale_param}, {
      "HTTP_ACCEPT_LANGUAGE"  => locale_http || ""
    }) { |c| c.cookies["l"] = cookie || ""}
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