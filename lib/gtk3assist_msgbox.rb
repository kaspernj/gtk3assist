class Gtk3assist::Msgbox
  #An array of possible arguments that the constructor accepts.
  ARGS_ALLOWED = [:msg, :parent, :run, :title, :type]
  
  #Various data like the current showing messagebox.
  DATA = {}
  
  #The Gtk::Dialog-object.
  attr_reader :dialog
  
  #The result of the dialog.
  attr_reader :result
  
  def self.current
    raise "No current showing message-box." if !DATA[:current]
  end
  
  #Constructor.
  def initialize(args)
    raise "'args' wasnt a hash." if !args.is_a?(Hash)
    args.each do |key, val|
      raise "Invalid argument: '#{key}'." if !ARGS_ALLOWED.include?(key)
    end
    
    raise "No ':msg' was given." if args[:msg].to_s.strip.empty?
    
    if !args[:title]
      case args[:type]
        when :warning
          args[:title] = _("Warning")
        when :yesno
          args[:title] = _("Question")
        when :info
          args[:title] = _("Information")
        else
          raise "Unknown type: '#{args[:type]}'."
      end
    end
    
    @dialog = Gtk::Dialog.new
    @dialog.resize(350, 1)
    @dialog.set_title(args[:title])
    
    DATA[:current] = self
    @dialog.signal_connect("destroy") do
      DATA.delete(:current)
    end
    
    box = Gtk::Box.new(Gtk::Orientation[:horizontal], 4)
    @dialog.get_content_area.add(box)
    
    case args[:type]
      when :warning, :info
        if args[:type] == :info
          image = Gtk::Image.new_from_stock(Gtk::STOCK_DIALOG_INFORMATION, Gtk::IconSize[:dialog])
        else
          image = Gtk::Image.new_from_stock(Gtk::STOCK_DIALOG_WARNING, Gtk::IconSize[:dialog])
        end
        
        box.pack_start(image, false, false, 4)
        image.show
        
        lab = Gtk::Label.new(args[:msg])
        lab.set_selectable(true)
        lab.set_justify(Gtk::Justification[:left])
        
        box.pack_start(lab, false, false, 4)
        lab.show
        
        but = Gtk::Button.new_from_stock(Gtk::STOCK_OK)
        but.signal_connect("clicked") do
          @result = Gtk::ResponseType[:ok]
          @dialog.response(@result)
        end
        
        res = Gtk::ResponseType[:ok]
        @dialog.get_action_area.add(but)
        but.show
      when :yesno
        image = Gtk::Image.new_from_stock(Gtk::STOCK_DIALOG_QUESTION, Gtk::IconSize[:dialog])
        
        box.pack_start(image, false, false, 4)
        image.show
        
        lab = Gtk::Label.new(args[:msg])
        lab.set_selectable(true)
        lab.set_justify(Gtk::Justification[:left])
        
        box.pack_start(lab, false, false, 4)
        lab.show
        
        but_yes = Gtk::Button.new_from_stock(Gtk::STOCK_YES)
        but_yes.signal_connect("clicked") do
          @result = Gtk::ResponseType[:yes]
          @dialog.response(@result)
        end
        
        but_no = Gtk::Button.new_from_stock(Gtk::STOCK_NO)
        but_no.signal_connect("clicked") do
          @result = Gtk::ResponseType[:no]
          @dialog.response(@result)
        end
      else
        raise "Unknown type: '#{args[:type]}'."
    end
    
    box.show
    @result = @dialog.run if !args.key?(:run) or args[:run]
  end
  
  #Runs the dialog.
  def run
    @result = @dialog.run
    return @result
  end
  
  #Shows the dialog but doesnt run it.
  def show
    @dialog.show
  end
  
  #Responds to the dialog.
  def respond(res)
    case res
      when :cancel, :no, :ok, :yes
        @result = Gtk::ResponseType[res]
        @dialog.response(@result)
      else
        raise "Unknown response: '#{res}'."
    end
  end
  
  #Returns the result as a string.
  def result_text
    raise "No result yet." if !@result
    return Gtk::ResponseType[@result].to_sym
  end
  
  #Contains a fallback method for '_' which is used to translate texts in the GetText-library.
  def method_missing(method, *args, &block)
    case method
      when :_
        return args[0]
      else
        raise NameError, "No such method: '#{method}'."
    end
  end
end