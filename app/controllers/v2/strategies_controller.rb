module V2
  class StrategiesController < BaseController
    layout false
    before_filter :load_strategy

    def show
      @bank_entry = BankEntry.find(params[:bank_entry_id])
    end

    def new
    end

    def create
      if @strategy.save
        account = Account.where(:name => params[:account_entry][:account_name]).first!
        account.update_attribute(:strategy_id, @strategy.id)
        @bank_entry = BankEntry.find(params[:bank_entry_id])
        render action: :show
      else
        render action: :new
      end
    end

  private
    def load_strategy
      @strategy =
        Strategy.where(id: params[:id]).first ||
        Strategy.new(params[:strategy])
    end
  end
end
