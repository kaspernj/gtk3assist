#This class contains code than can optimize productivity when coding comboboxes.
class Gtk3assist::Combobox
  #An array containing allowed arguments for the constructor.
  ARGS_ALLOWED = [:cb]
  
  #An array containing allowed arguments for the 'add_item'-method.
  ARGS_ALLOWED_ADD_ITEM = [:id, :title]
  
  #The combobox-widget that this object handels.
  attr_reader :cb
  
  #Constructor.
  def initialize(args = {})
    raise "'args' was not a hash." if !args.is_a?(Hash)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !ARGS_ALLOWED.include?(key)
    end
    
    @objs = {}
    
    if args[:cb]
      @cb = args[:cb]
    else
      @cb = Gtk::ComboBox.new
    end
    
    @rend = Gtk::CellRendererText.new
    @cb.pack_start(@rend, false)
    @cb.add_attribute(@rend, "text", 0)
    
    @model = Gtk::ListStore.new([GObject::TYPE_STRING, GObject::TYPE_STRING])
    @cb.set_model(@model)
    @cb.show
  end
  
  #Adds a new item to the combobox with ID and title.
  def add_item(args)
    raise "'args' was not a hash." if !args.is_a?(Hash)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !ARGS_ALLOWED_ADD_ITEM.include?(key)
    end
    
    raise "No ':title' was given." if !args[:title]
    raise "No ':id' was given." if !args[:id]
    
    iter = @model.append
    @model.set_value(iter, 0, args[:title])
    
    @objs[args[:id]] = {:iter => iter}
  end
  
  #Selects a certain item by id.
  def sel_id(args)
    raise "'args' was not a hash." if !args.is_a?(Hash)
    raise "No ':id' was given." if !args.key?(:id)
    
    @objs.each do |id, data|
      if id == args[:id]
        @cb.set_active_iter(data[:iter])
        return nil
      end
    end
    
    raise "Could not find item by that id: '#{args[:id]}'."
  end
  
  #Returns the selected item.
  def sel
    return self.items(:selected => true).next
  end
  
  #Enumerates over every single item in the combobox.
  def items(args = nil, &blk)
    enum = Enumerator.new do |y|
      if args and args[:selected]
        iter_cur = @cb.get_active_iter.last
      else
        iter_cur = @model.iter_first.last
      end
      
      while iter_cur
        match = true
        
        if match
          y << {
            :data => {
              :title => @model.get_value(iter_cur, 0).get_string
            }
          }
        end
        
        break if !@model.iter_next(iter_cur) or (args and args[:selected])
      end
    end
    
    if blk
      enum.each(&blk)
    else
      return enum
    end
  end
end