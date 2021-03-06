if defined?(Merb::Plugins)
  Merb::Plugins.config[:merb_sequel] = {}
  require File.join(File.dirname(__FILE__) / "merb" / "orms" / "sequel" / "connection")
  Merb::Plugins.add_rakefiles "merb_sequel" / "merbtasks"
  
  class Merb::Orms::Sequel::Connect < Merb::BootLoader

    after BeforeAppRuns

    def self.run
      Merb::Orms::Sequel.connect
      Merb::Orms::Sequel.register_session_type
    end

  end
  
end