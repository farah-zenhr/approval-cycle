class CreateDummyUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :dummy_users do |t|
      t.string :name

      t.timestamps
    end
  end
end
