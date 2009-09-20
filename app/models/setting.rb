class Setting < ActiveRecord::Base
  class SettingNotFound < RuntimeError; end
  
  # Set this to false if you want Setting to return nil instead of raising an error
  # when a setting can not be found
  cattr_accessor :raise_exception
  self.raise_exception = true
  
  # Set this to your memcache-client object (or any other cache that supports #get and #put methods)
  # or leave blank to disable caching. By default it looks for a CACHE constant that you
  # could set in your initializers
  cattr_accessor :ss_cache
  self.ss_cache = CACHE if defined?(CACHE)
  
  serialize :value
  
  class << self
    def method_missing(method, *args)
      method_name = method.to_s
      super(method, *args)
    rescue NoMethodError
      if method_name =~ /=$/
        clean_method_name = method_name.sub('=', '')
        set_value(clean_method_name, args.first)
      else
        self.ss_cache.get(cache_key(method_name)) || get_value(method_name)
      end
    end
    
  private
    def get_value(key)
      if r = find_by_key(key)
        self.ss_cache.put(cache_key(key), r.value)
      elsif self.raise_exception
        raise SettingNotFound, "The setting '#{key}' could not be found"
      else
        nil
      end
    end

    def set_value(key, value)
      rec = self.find_or_initialize_by_key(key)
      rec.update_attributes!(:value => value)
      
      self.ss_cache.put(cache_key(key), value)
    end
    
    def cache_key(key)
      "_settings_store/#{key}"
    end
  end
end
