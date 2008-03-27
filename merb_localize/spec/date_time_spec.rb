require File.join(File.dirname(__FILE__), "spec_helper")

describe GettextLocalize do
   
  before do
    GettextLocalize.set_locale('ca_ES')
    
    @ca_abbr_daynames = ["Dg","Dl","Dt","Dc","Dj","Dv","Ds"]
    @ca_abbr_monthnames = ["Gen","Feb","Mar","Abr","Mai","Jun","Jul","Ago","Set","Oct","Nov","Des"]
    @ca_daynames = ["Diumenge","Dilluns","Dimarts","Dimecres","Dijous","Divendres","Dissabte"]
    @ca_monthnames = ["Gener","Febrer","Març","Abril","Maig","Juny","Juliol","Agost","Setembre","Octubre","Novembre","Desembre"]

    # ensure DATE_FORMATS not overwritten by app
    GettextLocalize.send(:class_variable_set, '@@formats', {})
    Time::DATE_FORMATS.replace({:short =>"%d %b %H:%M", :rfc822=>"%a, %d %b %Y %H:%M:%S %z", :long=>"%B %d, %Y %H:%M", :db=>"%Y-%m-%d %H:%M:%S"})
    Date::DATE_FORMATS.replace({:short=>"%e %b", :long=>"%B %e, %Y"})
    DateTime::DATE_FORMATS.replace({:short=>"%e %b", :long=>"%B %e, %Y"})
  end

  it "should have correct daynames" do
    (1..7).each do |d|
      Date.new(2006,12,23+d).strftime("%a").should == @ca_abbr_daynames[d-1]
      Time.mktime(2006,12,23+d,0,0,0,0).strftime("%a").should == @ca_abbr_daynames[d-1]
      DateTime.new(2006,12,23+d,0,0,0,0).strftime("%a").should == @ca_abbr_daynames[d-1]
      Date.new(2006,12,23+d).strftime("%A").should == @ca_daynames[d-1]
      Time.mktime(2006,12,23+d,0,0,0,0).strftime("%A").should == @ca_daynames[d-1]
      DateTime.new(2006,12,23+d,0,0,0,0).strftime("%A").should == @ca_daynames[d-1]
    end
  end                             
  
  it "should have correct monthnames" do
    (1..12).each do |m|
      Date.new(2006,m,23).strftime("%b").should == @ca_abbr_monthnames[m-1]
      Time.mktime(2006,m,23,0,0,0,0).strftime("%b").should == @ca_abbr_monthnames[m-1]
      DateTime.new(2006,m,23,0,0,0,0).strftime("%b").should == @ca_abbr_monthnames[m-1]
      Date.new(2006,m,23).strftime("%B").should == @ca_monthnames[m-1]
      Time.mktime(2006,m,23,0,0,0,0).strftime("%B").should == @ca_monthnames[m-1]
      DateTime.new(2006,m,23,0,0,0,0).strftime("%B").should == @ca_monthnames[m-1]
    end
  end                               
  
  it "should provide the correct to_s methods for date objects" do
    pdate = Date.new(2006,12,24)
    ptime = Time.local(2006,12,24,0,0,0,0)
    pdatetime = DateTime.new(2006,12,24,0,0,0,0)

    pdate.to_s.should == "24-12-2006"
    ptime.to_s.should == "Dg 24 Des 00:00:00 CET 2006"
    pdatetime.to_s.should == "Dg 24 Des 00:00:00 2006"
    
    pdate.to_s(:default, true).should == "2006-12-24"
    ptime.to_s(:default, true).should == "Sun Dec 24 00:00:00 CET 2006"
    pdatetime.to_s(:default, true).should == "Sun Dec 24 00:00:00 2006"
    
    pdate.to_s(:long).should == "24 de Desembre, 2006"
    pdate.to_s(:short).should == "24 Des"
    
    ptime.to_s(:long).should == "24 de Desembre, 2006 00:00"
    ptime.to_s(:short).should == "24 Des 00:00"
    ptime.to_s(:db).should == "2006-12-24 00:00:00"
    
    pdatetime.to_s(:long).should == "24 de Desembre, 2006"
    pdatetime.to_s(:short).should == "24 Des"


    GettextLocalize.set_locale('en_US')

    pdate.to_s.should == "2006-12-24"
    ptime.to_s.should == "Sun Dec 24 00:00:00 CET 2006"
    pdatetime.to_s.should == "Sun Dec 24 00:00:00 2006"
    
    pdate.to_s(:default, true).should == "2006-12-24"
    ptime.to_s(:default, true).should == "Sun Dec 24 00:00:00 CET 2006"
    pdatetime.to_s(:default, true).should == "Sun Dec 24 00:00:00 2006"
    
    pdate.to_s(:long).should == "December 24, 2006" 
    pdate.to_s(:short).should == "24 Dec"
    
    ptime.to_s(:long).should == "December 24, 2006 00:00"
    ptime.to_s(:short).should == "24 Dec 00:00"
    ptime.to_s(:db).should == "2006-12-24 00:00:00"
    
    pdatetime.to_s(:long).should == "December 24, 2006"
    pdatetime.to_s(:short).should == "24 Dec"

    GettextLocalize.set_locale('es_ES')

    pdate.to_s.should == "24-12-2006"
    ptime.to_s.should == "Dom Dic 24 00:00:00 CET 2006"
    pdatetime.to_s.should == "Dom Dic 24 00:00:00 2006"
    
    pdate.to_s(:default, true).should == "2006-12-24"
    ptime.to_s(:default, true).should == "Sun Dec 24 00:00:00 CET 2006"
    pdatetime.to_s(:default, true).should == "Sun Dec 24 00:00:00 2006"
    
    pdate.to_s(:long).should == "24 de Diciembre, 2006"
    pdate.to_s(:short).should == "24 Dic"
    
    ptime.to_s(:long).should == "24 de Diciembre, 2006 00:00"
    ptime.to_s(:short).should == "24 Dic 00:00"
    ptime.to_s(:db).should == "2006-12-24 00:00:00"
    
    pdatetime.to_s(:long).should == "24 de Diciembre, 2006"
    pdatetime.to_s(:short).should == "24 Dic" 
  end

  it "should provide a correct stftime representation" do
    pdate = Date.new(2006,12,24)
    ptime = Time.mktime(2006,12,24,0,0,0,0)
    pdatetime = DateTime.new(2006,12,24,0,0,0,0)

    pdate.strftime("%d-%m-%Y").should == "24-12-2006"
    ptime.strftime("%a %b %d %H:%M:%S %Z %Y").should == "Dg Des 24 00:00:00 CET 2006"
    pdatetime.strftime("%a %b %d %H:%M:%S %Y").should == "Dg Des 24 00:00:00 2006"

    GettextLocalize.set_locale('en_US')

    pdate.strftime("%d-%m-%Y").should == "24-12-2006"
    ptime.strftime("%a %b %d %H:%M:%S %Z %Y").should == "Sun Dec 24 00:00:00 CET 2006"
    pdatetime.strftime("%a %b %d %H:%M:%S %Y").should == "Sun Dec 24 00:00:00 2006"

    GettextLocalize.set_locale('es_ES')

    pdate.strftime("%d-%m-%Y").should == "24-12-2006"
    ptime.strftime("%a %b %d %H:%M:%S %Z %Y").should == "Dom Dic 24 00:00:00 CET 2006"
    pdatetime.strftime("%a %b %d %H:%M:%S %Y").should == "Dom Dic 24 00:00:00 2006"
    
  end
  
end