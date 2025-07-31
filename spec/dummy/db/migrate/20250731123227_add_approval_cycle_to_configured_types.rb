class AddApprovalCycleToConfiguredTypes < ActiveRecord::Migration[7.2]
  def change
    
    
    
    # Add approval cycle columns to dummy_requests
    
    add_reference :dummy_requests, :approval_cycle_setup, foreign_key: true, index: true
    
    
    add_column :dummy_requests, :approval_cycle_status, :integer
    
    
    add_column :dummy_requests, :is_approval_cycle_reset, :boolean, default: false
    
    
    
  end
end
