class CreateDomainCountries < ActiveRecord::Migration[5.1]
  def change
    create_table :domain_countries do |t|
      t.timestamps
      t.string :domain
      t.string :country
      t.float :percentage
    end
    add_index :domain_countries, [:domain, :country], :unique => true
  end
end