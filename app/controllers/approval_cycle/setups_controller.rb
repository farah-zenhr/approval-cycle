module ApprovalCycle
  class SetupsController < ApplicationController
    before_action :set_setup, only: %i[show update destroy]

    def index
      @approval_cycles = ApprovalCycle::Setup.all
      render json: @approval_cycles
    end

    def show
      render json: @approval_cycle
    end

    def create
      if @approval_cycle.save
        render json: { message: "Created Successfully" }, status: :created
      else
        render json: { message: "Failure" }, status: :bad_request
      end
    end

    def update
      @approval_cycle = ApprovalCycleUpdater.call(approval_cycle:    @approval_cycle,
                                                  params:            approval_cycle_params,
                                                  apply_to_versions: params[:apply_to_versions])

      if @approval_cycle.errors.empty?
        render json: { message: "Updated Successfully" }, status: :ok
      else
        render json: { message: "Failed to update approval cycle" }, status: :bad_request
      end
    end

    def destroy
      if @approval_cycle.destroy
        render json: { message: "Deleted Successfully" }, status: :ok
      else
        render json: { message: "Failed to delete approval cycle" }, status: :bad_request
      end
    end

    private

    def set_approval_cycle
      @approval_cycle = ApprovalCycle::Setup.find(params[:id])
    end

    def approval_cycle_params
      params.require(:approval_cycle_setup).permit(
        :name,
        :skip_after,
        :setup_type,
        approval_cycle_approvers_attributes:      %i[id user_id user_type order],
        approval_cycle_watchers_attributes:      %i[id user_id user_type action],
        approval_cycle_action_takers_attributes: %i[id user_id user_type]
      )
    end
  end
end
