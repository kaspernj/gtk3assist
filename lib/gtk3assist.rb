require "gir_ffi"
require "gir_ffi-gtk3"

#This class has various sub-classes which can help developing applications using the 'gir_ffi-gtk'-gtk3-framework.
class Gtk3assist
  #Autoloader for subclasses.
  def self.const_missing(name)
    require "#{File.dirname(__FILE__)}/gtk3assist_#{name.to_s.downcase}.rb"
    raise "Still not defined: '#{name}'." if !Gtk3assist.const_defined?(name)
    return Gtk3assist.const_get(name)
  end
end