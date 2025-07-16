ApprovalCycle::Engine.routes.draw do
  namespace :approval_cycles do
    resources :action_takers, only: %i[index show create update destroy]
    resources :watchers, only: %i[index show create update destroy]
    resources :approvers, only: %i[index show create update destroy]
    resources :approvals, only: %i[index show create update destroy]
    resources :approval_cycles, only: %i[index show create update destroy]
  end
end
