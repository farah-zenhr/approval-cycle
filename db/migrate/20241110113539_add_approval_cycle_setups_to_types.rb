class AddApprovalCycleSetupsToTypes < ActiveRecord::Migration[7.2]
  def change
    ApprovalCycle.configuration.approval_cycle_setup_types.each_key do |type|
      table_name = type.to_s.pluralize.to_sym
      add_reference table_name, :approval_cycle_setup, foreign_key: true, index: true
      add_column table_name, :approval_cycle_status, :integer
      add_column table_name, :is_approval_cycle_reset, :boolean, default: false
    end
  end
end
