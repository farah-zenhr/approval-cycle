class CreateDummyRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :dummy_requests do |t|
      t.string :name

      t.timestamps
    end
  end
end
