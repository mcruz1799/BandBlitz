class Admin < ActiveRecord::Migration[5.1]
  def up
    adminBand = Band.new
    adminBand.name = "Admin Band"
    adminBand.description = "An initial band to create users"
    adminBand.save
    admin = User.new
    admin.first_name = "Admin"
    admin.last_name = "Admin"
    admin.email = "admin@example.com"
    admin.band_id = adminBand.id
    admin.password = "secret"
    admin.password_confirmation = "secret"
    admin.role = "admin"
    admin.save
  end
  def down
    admin = User.find_by_email "admin@example.com"
    User.delete admin
    band = Band.find_by_name "Admin Band"
    Band.delete band
  end
end
