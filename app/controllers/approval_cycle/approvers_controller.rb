module ApprovalCycle
  class ApproversController < ApplicationController
    before_action :set_approver, only: %i[show update destroy]

    def index
      @approvers = ApprovalCycle::Approver.all
      render json: @approvers
    end

    def show
      render json: @approver
    end

    def create
      if @approver.save
        render json: { message: "Created Successfully" }, status: :created
      else
        render json: { message: "Failure" }, status: :bad_request
      end
    end

    def update
      @approver.update(approver_params)
      if @approver.errors.empty?
        render json: { message: "Updated Successfully" }, status: :ok
      else
        render json: { message: "Failed to update approver" }, status: :bad_request
      end
    end

    def destroy
      if @approver.destroy
        render json: { message: "Deleted Successfully" }, status: :ok
      else
        render json: { message: "Failed to delete approver" }, status: :bad_request
      end
    end

    private

    def set_approver
      @approver = ApprovalCycle::Approver.find(params[:id])
    end

    def approver_params
      params.require(:approval_cycle_approver).permit(:order, :approval_cycle_setup_id, :user_type, :user_id)
    end
  end
end
