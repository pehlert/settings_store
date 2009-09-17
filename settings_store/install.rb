# Timestamp migration and copy to app's migrations folder
File.copy("assets/create_settings_store.rb", "#{RAILS_ROOT}/db/migrate/#{current_timestamp}_create_settings_store.rb")

def current_timestamp
  Time.now.strftime("%Y%M%d%H%M%S")
end