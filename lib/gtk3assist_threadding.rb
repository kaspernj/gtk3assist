class Gtk3assist::Threadding
  #Enables other threads to be run and interrupts to be used (<CTRL> + <C>).
  def self.enable_threadding(args = nil)
    #Never start this more than once.
    return nil if @enable_threadding
    @enable_threadding = true
    
    #Amount of time to check if a new thread wants to run.
    if args and args[:sleep]
      @time = args[:sleep]
    else
      @time = 100
    end
    
    @method = self.method(:enable_threadding_pass)
    
    #Call the method (which then calls itself based on timings).
    enable_threadding_pass
  end
  
  private
  
  #Passes to another running thread. Based on the time something else is running, the pass will be called again as soon as possible or waiting a small amount of time to check again if not.
  def self.enable_threadding_pass(*args)
    t_begin = Time.now.to_f
    Thread.pass
    t_run = Time.now.to_f - t_begin
    
    if t_run < 0.00001
      #Somehow the idle or timeout gets ignored unless this is here.
      Thread.pass
      
      #Run again after a small amount of time to prevent 100% CPU.
      GLib.timeout_add(GLib::PRIORITY_DEFAULT_IDLE, @time, @method, nil, nil)
      return false
    else
      #Somehow the idle or timeout gets ignored unless this is here.
      Thread.pass
      
      #Run again on next idle.
      GLib.idle_add(GLib::PRIORITY_DEFAULT_IDLE, @method, nil, nil)
      return false
    end
  end
end