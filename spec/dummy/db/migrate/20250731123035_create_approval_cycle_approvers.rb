class CreateApprovalCycleApprovers < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_cycle_approvers do |t|
      t.integer    :order,                null: false
      t.references :approval_cycle_setup, null: false, foreign_key: true, index: true
      t.references :user,                 null: false, polymorphic: true, index: true
    end
  end
end
