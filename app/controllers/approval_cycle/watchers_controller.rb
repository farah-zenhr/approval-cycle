module ApprovalCycle
  class WatchersController < ApplicationController
    before_action :set_watcher, only: %i[show update destroy]

    def index
      @watchers = ApprovalCycle::Watcher.all
      render json: @watchers
    end

    def show
      render json: @watcher
    end

    def create
      @watcher = ApprovalCycle::Watcher.new(watcher_params)

      if @watcher.save
        render json: @watcher, status: :created, location: @watcher
      else
        render json: @watcher.errors, status: :bad_request
      end
    end

    def update
      if @watcher.update(watcher_params)
        render json: @watcher, status: :ok, location: @watcher
      else
        render json: @watcher.errors, status: :bad_request
      end
    end

    def destroy
      @watcher.destroy
      head :no_content
    end

    private

    def set_watcher
      @watcher = ApprovalCycle::Watcher.find(params[:id])
    end

    def watcher_params
      params.require(:approval_cycle_watcher).permit(:action, :user_id, :user_type, :approval_cycle_setup_id)
    end
  end
end
