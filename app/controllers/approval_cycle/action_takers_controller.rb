module ApprovalCycle
  class ActionTakersController < ApplicationController
    before_action :set_approval_cycle_action_taker, only: %i[show update destroy]

    def index
      @approval_cycle_action_takers = ApprovalCycle::ActionTaker.all
      render json: @approval_cycle_action_takers
    end

    def show
      render json: @approval_cycle_action_taker
    end

    def create
      @approval_cycle_action_taker = ApprovalCycle::ActionTaker.new(approval_cycle_action_taker_params)
      if @approval_cycle_action_taker.save
        render json: @approval_cycle_action_taker, status: :created
      else
        render json: @approval_cycle_action_taker.errors, status: :bad_request
      end
    end

    def update
      if @approval_cycle_action_taker.update(approval_cycle_action_taker_params)
        render json: @approval_cycle_action_taker
      else
        render json: @approval_cycle_action_taker.errors, status: :bad_request
      end
    end

    def destroy
      @approval_cycle_action_taker.destroy
    end

    private

    def set_approval_cycle_action_taker
      @approval_cycle_action_taker = ApprovalCycle::ActionTaker.find(params[:id])
    end

    def approval_cycle_action_taker_params
      params.require(:approval_cycle_action_taker).permit(:user_id, :user_type, :approval_cycle_setup_id)
    end
  end
end
