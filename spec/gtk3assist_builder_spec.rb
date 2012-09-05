require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Gtk3assist_builder" do
  it "should work" do
    Gtk.init
    
    builder = Gtk::Builder.new
    
    gui = Gtk3assist::Builder.new(:builder => builder)
    gui.add_from_file("#{File.dirname(__FILE__)}/gtk3assist_builder.glade")
    gui.connect_signals{|h| method(h)}
    
    gui["window"].show_all
    
    gui["btnSave"].clicked
    gui["btnDelete"].clicked
    
    raise "Expected save-event to be called but it wasnt." if !@save_pressed
    raise "Expected delete-event to be called but it wasnt." if !@delete_pressed
    gui["window"].destroy
    
    #Gtk.main
  end
  
  def on_window_destroy
    #Gtk.main_quit
  end
  
  def on_btnSave_clicked
    @save_pressed = true
  end
  
  def on_btnDelete_clicked
    @delete_pressed = true
  end
end
