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
    tva.add_row(:data => {
      :id => 3,
      :name => "Matti"
    })
    tva.add_row(:data => {
      :id => 4,
      :name => "Nancy"
    })
    
    count = 0
    tva.rows do |data|
      count += 1
      #puts data
    end
    
    raise "Expected count to be 4 but it wasnt: '#{count}'." if count != 4
    
    kasper_removed = false
    last_data = nil
    
    tva.rows_remove do |data|
      last_data = data
      
      if data[:data][:name] == "Kasper" or data[:data][:name] == "Matti"
        kasper_removed = true
        true
      else
        false
      end
    end
    
    raise "Expected 'Kasper' to be removed but it wasnt." if !kasper_removed
    raise "Expected last item to be 'Nancy' but it wasnt." if last_data[:data][:name] != "Nancy"
    
    kasper_found = false
    count = 0
    tva.rows do |data|
      raise "Didnt expect 'Kasper' or 'Matti' to still exist but it did." if data[:data][:name] == "Kasper" or data[:data][:name] == "Matti"
      count += 1
    end
    
    raise "Expected count to be 4 but it wasnt: '#{count}'." if count != 2
    
    win.resize(640, 480)
    win.add(tv)
    win.show_all
    
    #Gtk.main
  end
end
