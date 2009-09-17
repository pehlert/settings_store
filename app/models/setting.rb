class Setting < ActiveRecord::Base
  class SettingNotFound < RuntimeError; end
  
  @memory = {}
  
  def value
    YAML::load(read_attribute(:value))
  end
  
  def value=(new_value)
    write_attribute(:value, new_value.to_yaml)
  end
  
  
  class << self
    def method_missing(method, *args)
      method_name = method.to_s
      super(method, *args)
    rescue NoMethodError
      if method_name =~ /=$/
        clean_method_name = method_name.sub('=', '')
        set_value(clean_method_name, args.first)
      else
        get_value(method_name)
      end
    end
    
  private
    def get_value(key)
      return @memory[key] if @memory.has_key?(key)

      if r = find_by_key(key)
        @memory[key] = r.value
      else
        raise SettingNotFound, "The setting '#{key}' could not be found"
      end
    end

    def set_value(key, value)
      rec = self.find_or_initialize_by_key(key)
      rec.update_attributes!(:value => value)
      
      @memory.delete(key)
    end
  end
end
