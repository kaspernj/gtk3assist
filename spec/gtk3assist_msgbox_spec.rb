require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Gtk3assist_msgbox" do
  it "should work" do
    Gtk.init
    
    
    msg = Gtk3assist::Msgbox.new(:type => :warning, :msg => "This is a test.", :run => false)
    msg.show
    msg.respond(:cancel)
    res = msg.result_text
    raise "Expected cancel but got: '#{res}'." if res != :cancel
    
    
    msg = Gtk3assist::Msgbox.new(:type => :yesno, :msg => "Do you like ice-cream?", :run => false)
    msg.show
    msg.respond(:yes)
    res = msg.result_text
    raise "Expected yes but got: '#{res}'." if res != :yes
  end
end
