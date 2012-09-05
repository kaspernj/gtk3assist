require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Gtk3assist_treeview" do
  it "should work" do
    Gtk.init
    
    win = Gtk::Window.new(:toplevel)
    GObject.signal_connect(win, "destroy") do
      Gtk.main_quit
    end
    
    tv = Gtk::TreeView.new
    
    tva = Gtk3assist::Treeview.new(:tv => tv, :cols => ["ID", "Name"], :model => :liststore)
    
    tva.add_row(:data => {
      :id => 1,
      :name => "Kasper"
    })
    
    tva.add_row(:data => {
      :id => 2,
      :name => "Christina"
    })
    
    count = 0
    tva.rows do |data|
      count += 1
      #puts data
    end
    
    raise "Expected count to be 2 but it wasnt: '#{count}'." if count != 2
    
    win.resize(640, 480)
    win.add(tv)
    win.show_all
    
    #Gtk.main
  end
end
