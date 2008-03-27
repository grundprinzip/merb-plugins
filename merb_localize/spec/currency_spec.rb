require File.join(File.dirname(__FILE__), "spec_helper")
require File.join(File.dirname(__FILE__), "controller", "controllers")

describe GettextLocalize do
  
  include GettextLocalize
  include GettextLocalize::Helpers::NumberHelper
                           
  before do         
    
    GettextLocalize.set_locale(nil)
    GettextLocalize.set_country(nil)
    
    Merb::Router.prepare do |r|
      r.default_routes
    end
  end
     
  it "should read the country options" do
    countries_yml_file = Pathname.new(GettextLocalize.get_countries_path()).realpath.to_s
    countries = YAML::load(File.open(countries_yml_file))
    GettextLocalize.set_country_options	
    country_options = GettextLocalize.get_country_options
    country_options.should == countries["es"]
  end
  
  it "should convert numbers to currency" do
    num = number_to_currency(1234567.8945)
    num.should == "1.234.567,89 €"
    
    num = number_to_currency(1234567.8945,{"unit"=>"%","separator"=>":","delimiter"=>"-","order"=>["unit","number"]})
    num.should == "%1-234-567:89"  
    
    GettextLocalize.set_locale("en_US")
    num = number_to_currency(1234567.8945)
    
    num.should == "$1,234,567.89"
    
  end
  

  def test_number_to_currency
    num = number_to_currency(1234567.8945)
    assert_equal "1.234.567,89 €", num
    num = number_to_currency(1234567.8945,{"unit"=>"%","separator"=>":","delimiter"=>"-","order"=>["unit","number"]})
    assert_equal "%1-234-567:89", num
    GettextLocalize.set_locale("en_US")
    num = number_to_currency(1234567.8945)
    assert_equal "$1,234,567.89", num
  end 
  
end