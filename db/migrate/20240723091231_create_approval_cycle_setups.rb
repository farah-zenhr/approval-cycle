class CreateApprovalCycleSetups < ActiveRecord::Migration[7.1]
  def change
    create_table :approval_cycle_setups do |t|
      t.integer    :approval_cycle_setup_type
      t.integer    :skip_after
      t.string     :name, null: false
      t.virtual    :latest, type: :boolean, as: '(latest_setup_version_id = id)', stored: true
      t.references :latest_setup_version, foreign_key: { to_table: :approval_cycle_setups }, index: true, null: false, default: -> { "currval('approval_cycle_setups_id_seq'::regclass)" }
      t.references :level, index: true, null: false, polymorphic: true
      t.timestamps
    end

    add_index :approval_cycle_setups, :name, using: 'gin', opclass: 'gin_trgm_ops'
  end
end
