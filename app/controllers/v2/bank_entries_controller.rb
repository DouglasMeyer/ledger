module V2
  class BankEntriesController < BaseController
    before_filter :load_account_names

    def index
      @bank_entries = bank_entries.includes(account_entries: :account)
    end

    def show
      render bank_entry
    end

    def edit
      bank_entry # populate @bank_entry
      @accounts = Account.where("deleted_at IS NULL").order(:position)
    end

    def update
      bank_entry.update_attributes!(params[:bank_entry])
      if request.xhr?
        render bank_entry
      else
        redirect_to action: :index
      end
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
