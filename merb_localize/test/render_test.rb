require File.dirname(__FILE__) + '/test_helper'

class RenderController < Merb::Controller
  
  self._template_root = File.dirname(__FILE__) / "views"           
  
  def test()
    render

  end               
  
  def rescue_action(e) raise; end
end

class  RenderControllerBeforeDefaultLocale < RenderController
  before {|c| c.set_default_locale("en_us") }
end

class  RenderControllerBeforeDefaultCountry < RenderController
  before {|c| c.set_default_country("es") }
end

class RenderControllerByEverything < RenderController
  before {|c| c.set_locale_by [:param, :cookie, :session, :header, :default], 'l' }
end


class RenderControllerTest < Test::Unit::TestCase
  include GettextLocalize
  include Merb::Test::ControllerHelper

  def set_controller(klass=nil)
    klass = RenderController if klass.nil?
    @controller = klass.new(fake_request)       
    @controller._dispatch("test")
  end

  def setup
    set_controller RenderController
    GettextLocalize.set_locale(nil)
    GettextLocalize.set_country(nil)
    #set_cookie("l",nil)
  end

  def assert_view_in_cat
    expect =<<EOF
locale: ca_ES
country: es
currency: 1.000,50 €
string: Gener
EOF
    assert_equal expect,@controller.body
  end

  def assert_view_in_spa
    expect =<<EOF
locale: es_ES
country: es
currency: 1.000,50 €
string: Enero
EOF
    assert_equal expect,@controller.body
  end

  def assert_view_in_usa
    expect =<<EOF
locale: en_US
country: us
currency: $1,000.50
string: January
EOF
    assert_equal expect,@controller.body
  end

  def test_should_read_locale
    set_controller RenderController
    GettextLocalize.set_locale("en_US")
    assert_equal "en_US", GettextLocalize.locale     
    @controller._dispatch("test")
    GettextLocalize.set_locale("ca-es")
    assert_equal "ca_ES", GettextLocalize.locale
  end

  def test_controller_should_set_defaults
    set_controller RenderController
    GettextLocalize.default_locale = "ca-es"     
    @controller._dispatch("test")
    assert_view_in_cat
    GettextLocalize.default_locale = "en-us"    
    
    @controller._dispatch("test")
    assert_view_in_usa
  end

  def test_controler_should_overwrite_defaults
    set_controller RenderControllerBeforeDefaultLocale
    GettextLocalize.default_locale = "ca-es"
    @controller._dispatch("test")
    assert_view_in_usa

    set_controller RenderControllerBeforeDefaultCountry
    GettextLocalize.default_locale = "ca"
    @controller._dispatch("test")
    assert_view_in_cat
  end

  def test_controller_should_set_locale_by_everything
    set_controller RenderControllerByEverything
    GettextLocalize.default_locale = "ca-es"
    #@controller._dispatch("test")
    #assert_view_in_cat             
    
    @controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'en-us'
    @controller._dispatch("test")
    assert_view_in_usa     
              
    @controller.session['l'] = 'ca-es'
    @controller._dispatch("test")
    assert_view_in_cat           
    
    @controller.cookies[:l] = 'en-us'
    @controller._dispatch("test")
    assert_view_in_usa
      
    @controller.params["l"] = "ca-es"
    @controller._dispatch("test")
    assert_view_in_cat
  end

  def test_controller_should_set_locale_by_header
    set_controller RenderControllerByEverything   
    @controller.request.env['HTTP_ACCEPT_LANGUAGE'] = ""
    GettextLocalize.default_locale = "ca-es"
    @controller._dispatch("test")
    assert_view_in_cat
    
    @controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'en-us'
    @controller._dispatch("test")
    assert_view_in_usa
    @controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'es-es,es;q=0.8,en-us;q=0.5,en;q=0.3'
    @controller._dispatch("test")
    assert_view_in_spa
    @controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'lo-la,li;q=0.8,en-us;q=0.5,en;q=0.3'
    @controller._dispatch("test")
    assert_view_in_usa
    @controller.request.env['HTTP_ACCEPT_LANGUAGE'] = 'la-lo,lu,es-es'
    @controller._dispatch("test")
    assert_view_in_spa
  end

  def test_controller_should_not_memorize_locale_by_param
    set_controller RenderControllerByEverything    
    @controller.request.env['HTTP_ACCEPT_LANGUAGE'] = ""
    GettextLocalize.default_locale = "ca-es"
    @controller._dispatch("test")
    assert_view_in_cat
    @controller.params["l"] = "en-us"
    @controller._dispatch("test")
    assert_view_in_usa      
    @controller.params.delete("l")
    @controller._dispatch("test")
    assert_view_in_cat
    @controller.params["l"] = "es"
    @controller._dispatch("test")
    assert_view_in_spa            
    @controller.params.delete("l")
    @controller._dispatch("test")
    assert_view_in_cat
  end

  def test_controller_should_not_memorize_locale_by_session
    set_controller RenderControllerByEverything
    GettextLocalize.default_locale = "ca-es"
    get :test
    assert_view_in_cat
    session["l"] = "en-us"
    get :test
    assert_view_in_usa
    session["l"] = ""
    get :test
    assert_view_in_cat
  end

  def test_controller_should_not_memorize_locale_by_cookie
    set_controller RenderControllerByEverything
    GettextLocalize.default_locale = "ca-es"
    get :test
    assert_view_in_cat
    set_cookie("l", "en-us")
    get :test
    assert_view_in_usa
    set_cookie("l","")
    get :test
    assert_view_in_cat
  end

  def test_controller_should_find_symbols_and_strings_in_cookies
    set_controller RenderControllerByEverything
    GettextLocalize.default_locale = "ca-es"
    get :test
    assert_view_in_cat
    set_cookie("l","en-us")
    get :test
    assert_view_in_usa
    set_cookie(:l,"es")
    get :test
    assert_view_in_spa
    set_cookie(:l,"")
    get :test
    # in cookis "l" gets overwritten by :l
    assert_view_in_cat
    set_cookie("l","es")
    get :test
    assert_view_in_spa
  end

  def test_controller_should_find_symbols_and_strings_in_session
    set_controller RenderControllerByEverything
    GettextLocalize.default_locale = "ca-es"
    get :test
    assert_view_in_cat
    session["l"] = "en-us"
    get :test
    assert_view_in_usa
    session[:l] = "es"
    get :test
    assert_view_in_spa
    session[:l] = ""
    get :test
    assert_view_in_usa
    session["l"] = ""
    get :test
    assert_view_in_cat
  end

  def test_controller_should_find_symbols_and_strings_in_params
    set_controller RenderControllerByEverything
    GettextLocalize.default_locale = "ca-es"
    get :test
    assert_view_in_cat
    get :test, "l" => "en-us"
    assert_view_in_usa
    get :test, :l => "es", "l" => "en-us"
    assert_view_in_spa
    get :test, :l => "", "l" => "en-us"
    # this is because of params indiferent
    # access overwrites "l" with :l
    assert_view_in_cat
    get :test, :l => "", "l" => ""
    assert_view_in_cat
  end

  def test_activerecord_should_overwrite_date_quoting
    GettextLocalize.set_locale('ca-es')
    begin
      sql = ActiveRecord::Base.connection();
      sql.drop_table(:date_test) if sql.tables.include?(:date_test)
      sql.create_table :date_test do |t|
        t.column "name", :string
        t.column "updated_at", :datetime, :null => false
      end
      insert = ["INSERT INTO date_test VALUES (?,?,?);",1,'lala',Date.new(2000,1,1)]
      sql.execute(ActiveRecord::Base.send(:sanitize_sql,insert))

      select = ["SELECT * FROM date_test WHERE updated_at < ?",Date.new(2006,12,24)]
      result = sql.execute(ActiveRecord::Base.send(:sanitize_sql,select))
      assert_equal 1,result.to_a.size
      assert_equal "lala",result.to_a.first[1]

      select = ["SELECT * FROM date_test WHERE updated_at < ?",Time.now]
      result = sql.execute(ActiveRecord::Base.send(:sanitize_sql,select))
      assert_equal 1,result.to_a.size
      assert_equal "lala",result.to_a.first[1]

      select = ["SELECT * FROM date_test WHERE updated_at < ?",DateTime.now]
      result = sql.execute(ActiveRecord::Base.send(:sanitize_sql,select))
      assert_equal 1,result.to_a.size
      assert_equal "lala",result.to_a.first[1]
    ensure
      sql.drop_table(:date_test) if sql.respond_to?(:drop_table)
      GettextLocalize.set_locale(nil)
    end
  end

end