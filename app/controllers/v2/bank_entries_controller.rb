module V2
  class BankEntriesController < BaseController

    def index
      @account_names = Account.order(:name).pluck(:name)
      @bank_entries = bank_entries.includes(account_entries: :account)
    end

    def edit
      bank_entry # populate @bank_entry
      render layout: false
    end

    def update
      bank_entry.update_attributes!(params[:bank_entry])
      render text: ''
    end

  private
    def bank_entries
      @bank_entries ||= BankEntry.order("date DESC, id DESC").limit(100)
    end
    def bank_entry
      @bank_entry ||= bank_entries.find(params[:id])
    end
  end
end
