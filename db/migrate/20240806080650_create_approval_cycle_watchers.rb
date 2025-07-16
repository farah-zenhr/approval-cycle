class CreateApprovalCycleWatchers < ActiveRecord::Migration[7.1]
  def change
    create_table :approval_cycle_watchers do |t|
      t.integer    :action
      t.references :user,           null: false, polymorphic: true, index: true
      t.references :approval_cycle_setup, null: false, foreign_key: true, index: true
      t.timestamps
    end

    add_index :approval_cycle_watchers, %i[user_id user_type approval_cycle_setup_id action], unique: true, name: 'index_watchers_on_user_id_and_setup_id_and_action'
  end
end
