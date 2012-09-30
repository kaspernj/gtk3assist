#This class contains various code that can greatly speed up the building and handeling of treeviews.
class Gtk3assist::Treeview
  #The treeview that this object manipulates.
  attr_reader :tv
  
  #The model-object that is used by the treeview.
  attr_reader :model
  
  #An array of allowed arguments for the 'initialize'-method.
  ALLOWED_ARGS = [:tv, :cols, :model, :sort_col]
  
  #Constructor.
  def initialize(args)
    raise "'args' was not a hash." if !args.is_a?(Hash)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !ALLOWED_ARGS.include?(key)
    end
    
    @columns = []
    @column_count = 0
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
    
    self.sort_col = args[:sort_col] if args.key?(:sort_col)
  end
  
  #Initializes a new list-store on the treeview.
  def init_liststore
    liststore_args = []
    @columns.each do |col_data|
      if col_data[:type] == :string or !col_data[:type]
        liststore_args << GObject::TYPE_STRING
      else
        raise "Unknown column-type: '#{col_data[:type]}'."
      end
    end
    
    @model = Gtk::ListStore.new(liststore_args)
    @tv.set_model(@model)
  end
  
  def sort_col=(col_id)
    count = 0
    @columns.each do |col_data|
      if col_data[:id] == col_id
        @model.set_sort_column_id(count, Gtk::SortType[:ascending])
        return nil
      end
      
      count += 1
    end
    
    raise "Could not find a column by that ID: '#{col_id}'."
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
    count = @column_count
    
    @columns << {
      :col => col,
      :lab => lab,
      :id => args[:id],
      :type => args[:type]
    }
  end
  
  #Add a new row to the treeview.
  def add_row(args)
    raise "''args' wasnt a hash." if !args.is_a?(Hash)
    raise "No ':data'-array was given." if !args[:data]
    
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
        
        if col_data[:type] == :string or !col_data[:type]
          @model.set_value(iter, count, val.to_s)
        else
          raise "Unknown column-type: '#{col_data[:type]}'."
        end
        
        count += 1
      end
      
      return {:iter => iter}
    else
      raise "Unknown model: '#{@model.class.name}'."
    end
  end
  
  def rows_remove(args = nil)
    #Containing the ID's that should be removed (minus length to account for cursor changes).
    removes = []
    
    #Avoid counting length of 'removes' all the time.
    removes_count = 0
    
    #Calculate which rows should be removed by yield'ing and checking for true. Then adding ID (minus remove-count) to 'removes'-array.
    self.rows(args) do |data|
      res = yield(data)
      
      if res == true
        removes << @model.path(data[:iter]).to_string.to_i - removes_count
        removes_count += 1
      end
    end
    
    #Remove rows by their IDs (minus removes-count).
    removes.each do |id|
      path = Gtk::TreePath.new_from_string(id.to_s)
      iter = @model.iter(path).last
      @model.remove(iter)
    end
    
    return nil
  end
  
  #Enumerates over every row in the treeview.
  def rows(args = nil, &block)
    enum = Enumerator.new do |y|
      iter_cur = @model.iter_first.last
      
      while iter_cur
        match = true
        sel_val = @tv.get_selection.iter_is_selected(iter_cur) rescue false
        match = false if args and args[:selected] and !sel_val
        
        if match
          data = {}
          count = 0
          
          @columns.each do |col_data|
            if col_data[:type] == :string or !col_data[:type]
              data[col_data[:id]] = @model.get_value(iter_cur, count).get_string
            else
              raise "Unknown column-type: '#{col_data[:type]}'."
            end
            
            count += 1
          end
          
          y << {
            :sel => sel_val,
            :data => data,
            :iter => iter_cur
          }
        end
        
        break if !@model.iter_next(iter_cur)
      end
    end
    
    if block
      enum.each(&block)
      return nil
    else
      return enum
    end
  end
  
  #Returns the first selected row found.
  def sel
    self.rows(:selected => true).each do |data|
      return data if data[:sel]
    end
    
    return nil
  end
end