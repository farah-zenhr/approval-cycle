class CreateApprovalCycleObjectActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :approval_cycle_object_activities do |t|
      t.references :object,     polymorphic: true, index: true, null: false
      t.references :created_by, polymorphic: true, index: true, null: false
      t.references :updated_by, polymorphic: true, index: true
      t.datetime   :updated_at
    end
  end
end
