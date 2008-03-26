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