class CreateApprovalCycleActionTakers < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_cycle_action_takers do |t|
      t.references :user,                 null: false, polymorphic: true, index: true
      t.references :approval_cycle_setup, null: false, foreign_key: true, index: true
      t.timestamps
    end

    add_index :approval_cycle_action_takers, %i[user_id user_type approval_cycle_setup_id], unique: true, name: 'index_action_takers_on_user_id_and_setup_id'
  end
end
