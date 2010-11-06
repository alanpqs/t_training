class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :name
      t.string :country_code
      t.string :currency_code
      t.string :phone_code
      t.integer :region_id

      t.timestamps
    end
  end

  def self.down
    drop_table :countries
  end
end
