class CreateApprovalCycleApprovals < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_cycle_approvals do |t|
      t.string     :status
      t.references :approvable, polymorphic: true
      t.references :approval_cycle_approver, foreign_key: true
      t.string     :rejection_reason
      t.datetime   :received_at
    end
  end
end
