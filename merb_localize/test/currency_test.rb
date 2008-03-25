require File.dirname(__FILE__) + '/test_helper'

class CurrencyTest < Test::Unit::TestCase
  include GettextLocalize
  include GettextLocalize::Helpers::NumberHelper
  #include ActionView::Helpers::NumberHelper

  def setup
    GettextLocalize.set_locale('ca_ES')
    @ca_months = ["Gener","Febrer","Març","Abril","Maig","Juny","Juliol","Agost","Setembre","Octubre","Novembre","Desembre"]
  end
  
  def test_country_options
    countries_yml_file = Pathname.new(GettextLocalize.get_countries_path()).realpath.to_s
    countries = YAML::load(File.open(countries_yml_file))
    GettextLocalize.set_country_options	
    country_options = GettextLocalize.get_country_options
    assert_equal country_options, countries["es"]
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
