module ApprovalCycle
  class ApprovalsController < ApplicationController
    before_action :set_approval, only: %i[show update destroy]

    def index
      @approvals = ApprovalCycle::Approval.all
      render json: @approvals
    end

    def show
      render json: @approval
    end

    def create
      @approval = ApprovalCycle::Approval.new(approval_params)
      if @approval.save
        render json: @approval, status: :created
      else
        render json: @approval.errors, status: :bad_request
      end
    end

    def update
      if @approval.update(approval_params)
        render json: @approval
      else
        render json: @approval.errors, status: :bad_request
      end
    end

    def destroy
      if @approval.destroy
        render json: { message: "Deleted Successfully" }, status: :ok
      else
        render json: { message: "Failed to delete approval" }, status: :bad_request
      end
    end

    private

    def set_approval
      @approval = ApprovalCycle::Approval.find(params[:id])
    end

    def approval_params
      params.require(:approval_cycle_approval).permit(:status, :approvable_id, :approvable_type, :approval_cycle_approver_id, :rejection_reason, :received_at)
    end
  end
end
