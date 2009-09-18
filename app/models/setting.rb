class Setting < ActiveRecord::Base
  class SettingNotFound < RuntimeError; end
  
  # Set this to false if you want Setting to return nil instead of raising an error
  # when a setting can not be found
  cattr_accessor :raise_exception
  self.raise_exception = true
  
  serialize :value
  @memory = {}
  
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
      elsif self.raise_exception
        raise SettingNotFound, "The setting '#{key}' could not be found"
      else
        nil
      end
    end

    def set_value(key, value)
      rec = self.find_or_initialize_by_key(key)
      rec.update_attributes!(:value => value)
      
      @memory.delete(key)
    end
  end
end
