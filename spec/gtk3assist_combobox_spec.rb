require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Gtk3assist_combobox" do
  it "should work" do
    Gtk.init
    
    win = Gtk::Window.new(:toplevel)
    win.resize(640, 5)
    win.signal_connect("destroy") do
      Gtk.main_quit
    end
    
    cba = Gtk3assist::Combobox.new
    cba.add_item(:id => 1, :title => "Kasper")
    cba.add_item(:id => 2, :title => "Christina")
    
    win.add(cba.cb)
    win.show_all
    
    cba.sel_id(:id => 1)
    data = cba.sel
    
    raise "Expected selected data to be a hash but it wasnt: '#{data.class.name}'." if !data.is_a?(Hash)
    raise "Expected selected title to be 'Kasper' but it wasnt: '#{data[:data][:title]}'." if data[:data][:title] != "Kasper"
    
    cba.sel_id(:id => 2)
    data = cba.sel
    
    raise "Expected selected data to be a hash but it wasnt: '#{data.class.name}'." if !data.is_a?(Hash)
    raise "Expected selected title to be 'Kasper' but it wasnt: '#{data[:data][:title]}'." if data[:data][:title] != "Christina"
    
    count = 0
    cba.items do |data|
      #puts data
      count += 1
    end
    
    raise "Expected count to be 2 but it wasnt: '#{count}'." if count != 2
    
    #Gtk.main
  end
end
