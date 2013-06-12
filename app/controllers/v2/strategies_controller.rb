module V2
  class StrategiesController < BaseController
    before_filter :load_strategy

    def index
      @accounts = Account.not_deleted.order(:position)
    end

    def show
      layout false
      @bank_entry = BankEntry.find(params[:bank_entry_id])
      @account = Account.find(params[:account_id])
      @entry_ammount = params[:entry_ammount].to_f
    end

    def new
      layout false
      @bank_entry_id = params[:bank_entry_id]
      @account_id = params[:account_id]
      @entry_ammount = params[:entry_ammount].to_f
    end

    def create
      layout false
      if @strategy.save
        @account = Account.find(params[:account_id])
        @account.update_attribute(:strategy_id, @strategy.id)
        @bank_entry = BankEntry.find(params[:bank_entry_id])
        @entry_ammount = params[:entry_ammount].to_f
        render action: :show
      else
        render action: :new
      end
    end

  private
    def load_strategy
      @strategy =
        Strategy.where(id: params[:id]).first ||
        Strategy.new(params.permit(strategy: [ :strategy_type, :variable, :ammount, :notes ])[:strategy])
    end
  end
end
