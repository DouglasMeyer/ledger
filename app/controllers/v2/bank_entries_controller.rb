module V2
  class BankEntriesController < BaseController
    before_filter :load_account_names

    def index
      @bank_entries = bank_entries.includes(account_entries: :account)
    end

    def update
      bank_entry.update_attributes!(params[:bank_entry])
      render bank_entry
    end

  private
    def bank_entries
      @bank_entries ||= BankEntry.order("date DESC, id DESC").limit(100)
    end
    def bank_entry
      @bank_entry ||= bank_entries.find(params[:id])
    end

    def load_account_names
      @account_names = Account.order(:name).pluck(:name)
    end
  end
end
