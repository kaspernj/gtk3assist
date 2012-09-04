#This class contains various code that can greatly speed up the building and handeling of treeviews.
class Gtk3assist::Treeview
  #The treeview that this object manipulates.
  attr_reader :tv
  
  #The model-object that is used by the treeview.
  attr_reader :model
  
  #An array of allowed arguments for the 'initialize'-method.
  ALLOWED_ARGS = [:tv, :cols, :model]
  
  #Constructor.
  def initialize(args)
    raise "'args' was not a hash." if !args.is_a?(Hash)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !ALLOWED_ARGS.include?(key)
    end
    
    @columns = []
    @tv = args[:tv]
    raise "No ':tv' argument was given." if !@tv.is_a?(Gtk::TreeView)
    
    if args[:cols]
      args[:cols].each do |val|
        self.add_column(val)
      end
    end
    
    if args[:model]
      if args[:model] == :liststore
        self.init_liststore
      else
        raise "Unknown model: '#{args[:model]}'."
      end
    end
  end
  
  #Initializes a new list-store on the treeview.
  def init_liststore
    liststore_args = []
    @columns.each do |col_data|
      if col_data[:type] == :string
        liststore_args << GObject::TYPE_STRING
      else
        raise "Unknown column-type: '#{col_data[:type]}'."
      end
    end
    
    @model = Gtk::ListStore.new(liststore_args)
    @tv.set_model(@model)
  end
  
  #Adds a new column to the treeview.
  def add_column(args)
    if args.is_a?(Hash)
      #ignore.
    elsif args.is_a?(String)
      args = {:type => :string, :title => args, :id => args.to_s.downcase.to_sym}
    else
      raise "Unknown argument given: '#{argument.class.name}'."
    end
    
    renderer = Gtk::CellRendererText.new
    lab = Gtk::Label.new(args[:title])
    
    col = Gtk::TreeViewColumn.new
    col.set_widget(lab)
    col.pack_start(renderer, true)
    col.add_attribute(renderer, "text", @columns.length)
    
    lab.show
    @tv.append_column(col)
    
    @columns << {
      :col => col,
      :lab => lab,
      :id => args[:id],
      :type => args[:type]
    }
  end
  
  #Add a new row to the treeview.
  def add_row(args)
    if @model.is_a?(Gtk::ListStore)
      data = []
      @columns.each do |col_data|
        found = false
        args[:data].each do |key, val|
          if key == col_data[:id]
            data << val
            found = true
            break
          end
        end
        
        raise "Not found: '#{col_data[:id]}' (#{col_data})." if !found
      end
      
      iter = @model.append
      count = 0
      data.each do |val|
        col_data = @columns[count]
        
        if col_data[:type] == :string
          @model.set_value(iter, count, val.to_s)
        else
          raise "Unknown column-type: '#{col_data[:type]}'."
        end
        
        count += 1
      end
    else
      raise "Unknown model: '#{@model.class.name}'."
    end
  end
  
  #Enumerates over every row in the treeview.
  def rows(args = nil, &block)
    enum = Enumerator.new do |y|
      iter_cur = @model.iter_first.last
      
      while iter_cur
        match = true
        
        if match
          data = []
          @columns.each do |col_data|
            if col_data[:type] == :string
              data << @model.get_value(iter_cur, 1).get_string
            else
              raise "Unknown column-type: '#{col_data[:type]}'."
            end
          end
          
          y << {:data => data}
        end
        
        break if !@model.iter_next(iter_cur)
      end
    end
    
    if block
      enum.each(&block)
    else
      return enum
    end
  end
end