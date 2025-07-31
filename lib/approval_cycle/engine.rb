module ApprovalCycle
  class Engine < ::Rails::Engine
    isolate_namespace ApprovalCycle

    # Load rake tasks
    rake_tasks do
      load 'tasks/approval_cycle_tasks.rake'
    end

    # Auto-load migrations (Rails will handle this automatically)
    config.paths.add 'db/migrate', with: 'db/migrate', glob: '*.rb'
  end
end
