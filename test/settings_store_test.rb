require 'test_helper'

class SettingsStoreTest < ActiveSupport::TestCase
  Fixtures.create_fixtures(File.dirname(__FILE__) + '/fixtures', :settings)
  
  context "The settings store" do
    
    should "return existing configuration options" do
      assert_nothing_raised { Setting.string_example }
      assert_not_nil Setting.string_example
    end
    
    should "return configuration options in proper data type" do
      assert_instance_of String, Setting.string_example
      assert_instance_of Float, Setting.float_example
    end
    
    should "raise SettingNotFound if a setting is not present" do
      assert_raise(Setting::SettingNotFound) { Setting.invalid }
    end
    
    should "return nil if raise_exception is disabled and a setting is not present" do
      Setting.raise_exception = false
      assert_nothing_raised { Setting.invalid }
      assert_nil Setting.invalid
    end
    
    should "store new configuration options" do 
      assert_nothing_raised { Setting.new_setting = "some value" }
      assert_equal Setting.new_setting, "some value"
    end
    
    should "serialize complex objects correctly" do
      object = [1, 1.2, { :foo => :bar }]
      Setting.complex = object
      assert_equal object, Setting.complex
    end
  end
end
