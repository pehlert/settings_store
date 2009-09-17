class CreateSettingsStore < ActiveRecord::Migration
  def self.up
    create_table :settings, :id => false do |t|
      t.string :key, :null => false, :uniq => true
      t.text :value
    end
    
    add_index :settings, :key
  end

  def self.down
    drop_table :settings
    remove_index :settings, :key
  end
end