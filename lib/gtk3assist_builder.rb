#Helper class for Gtk::Builder which can do automatic signal-connect by scanning the Xml-file and more.
class Gtk3assist::Builder
  #Array containing allowed arguments for contructor.
  ARGS_ALLOWED = [:builder]
  
  #Constructor.
  def initialize(args)
    raise "'args' was not a hash." if !args.is_a?(Hash)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !ARGS_ALLOWED.include?(key)
    end
    
    @builder = args[:builder]
  end
  
  #Adds the given filepath to the builder and sets filepath for signal-connects.
  def add_from_file(fpath)
    @fpath = fpath
    @builder.add_from_file(fpath)
  end
  
  #Returns a widget from a given key.
  def [](key)
    obj = @builder.get_object(key)
    raise "No object by that name: '#{key}'." if !obj
    return obj
  end
  
  #Connects all signals to methods given by the supplied block.
  def connect_signals(&blk)
    str = File.read(@fpath)
    
    require "xmlsimple"
    data = XmlSimple.xml_in(str)
    connect_signals_from_filepath_helper(data, blk)
  end
  
  private
  
  #Used to recursivly scan XML-file for signals.
  def connect_signals_from_filepath_helper(data, blk)
    data.each do |item|
      if item.is_a?(Hash) and item.key?("id") and item.key?("signal")
        item["signal"].each do |signal_data|
          method = blk.call(signal_data["handler"])
          object = self[item["id"].to_s]
          
          object.signal_connect(signal_data["name"]) do |*args|
            #Convert arguments to fit the arity-count of the Proc-object (the block, the method or whatever you want to call it).
            newargs = []
            0.upto(method.arity - 1) do |number|
              if paras[number]
                newargs << args[number]
              end
            end
            
            method.call(*newargs)
          end
        end
      end
      
      if item.is_a?(Array) or item.is_a?(Hash)
        connect_signals_from_filepath_helper(item, blk)
      end
    end
  end
end