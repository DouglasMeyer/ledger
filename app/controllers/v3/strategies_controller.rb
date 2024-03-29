module V3
  class StrategiesController < BaseController
    before_action :load_strategy

    def index
      @accounts = Account.not_deleted.order(:position)
    end

    def show
      @bank_entry = BankEntry.find_by_id(params[:bank_entry_id])
      @account = Account.find(params[:account_id])
      @entry_amount = params[:entry_amount].to_f
      render layout: false
    end

    def new
      @bank_entry_id = params[:bank_entry_id]
      @account_id = params[:account_id]
      @entry_amount = params[:entry_amount].to_f
      render layout: false
    end

    def create
      if @strategy.save
        @account = Account.find(params[:account_id])
        @account.update_attribute(:strategy_id, @strategy.id)
        @bank_entry = BankEntry.find_by_id(params[:bank_entry_id])
        @entry_amount = params[:entry_amount].to_f
        render layout: false, action: :show
      else
        render layout: false, action: :new
      end
    end

    private

    def load_strategy
      @strategy =
        Strategy.where(id: params[:id]).first ||
        Strategy.new(params.permit(strategy: [ :strategy_type, :variable, :amount, :notes ])[:strategy])
    end
  end
end
