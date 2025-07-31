class CreateApprovalCycleSetups < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_cycle_setups do |t|
      t.integer    :approval_cycle_setup_type
      t.integer    :skip_after
      t.string     :name, null: false
      t.boolean    :latest, default: true, null: false
      t.references :latest_setup_version, foreign_key: { to_table: :approval_cycle_setups }, index: true, null: true
      t.references :level, index: true, null: false, polymorphic: true
      t.timestamps
    end

    add_index :approval_cycle_setups, :name
  end
end
