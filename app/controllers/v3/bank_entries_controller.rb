module V3
  class BankEntriesController < BaseController
    before_action :load_account_names

    def show
      render bank_entry
    end

    def edit
      bank_entry # populate @bank_entry
      @accounts = Account.not_deleted.order(:position)
      @distribute_as_income = bank_entry.account_entries.where("account_entries.strategy_id IS NOT NULL").any?
    end

    def update
      update_params = params
                      .require(:bank_entry)
                      .permit(account_entries_attributes: [
                        :id,
                        :account_name,
                        :account_id,
                        :amount,
                        :_destroy
                      ])
      bank_entry.update_attributes! update_params
      if request.xhr?
        render bank_entry
      else
        redirect_to v3_root_path(anchor: '/entries')
      end
    end

    def create
      new_bank_entry.assign_attributes params.require(:bank_entry).permit(:date, :description)
      new_bank_entry.save!

      new_bank_entry.update_attributes!(params.require(:bank_entry).permit(account_entries_attributes: [
        :account_name, :amount, :_destroy
      ]))
      render new_bank_entry
    end

    private

    def bank_entry
      @bank_entry ||= BankEntry.find(params[:id])
    end

    def new_bank_entry
      @new_bank_entry ||= BankEntry.new do |be|
        be.amount_cents = 0
        be.date = Date.today
      end
    end

    def load_account_names
      @account_names = Account.not_deleted.order(:name).pluck(:name)
    end
  end
end
