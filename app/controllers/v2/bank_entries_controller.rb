module V2
  class BankEntriesController < BaseController
    before_filter :load_account_names

    def index
      @bank_entries = BankEntry.includes(account_entries: :account)
      @bank_entry_pages = @bank_entries.count / 25
      @bank_entries = @bank_entries.offset(params[:page].to_i * 25) if params[:page]
      @bank_entries = @bank_entries.limit(25)
      new_bank_entry.account_entries.build
    end

    def show
      render bank_entry
    end

    def edit
      bank_entry # populate @bank_entry
      @accounts = Account.where("deleted_at IS NULL").order(:position)
      @distribute_as_income = bank_entry.account_entries.where("account_entries.strategy_id IS NOT NULL").any?
    end

    def update
      bank_entry.update_attributes!(params[:bank_entry])
      if request.xhr?
        render bank_entry
      else
        redirect_to action: :index
      end
    end

    def create
      account_entries_attributes = params[:bank_entry].delete(:account_entries_attributes)
      new_bank_entry.assign_attributes(params[:bank_entry], as: :creator)
      new_bank_entry.save!
      new_bank_entry.update_attributes!(account_entries_attributes: account_entries_attributes)
      render new_bank_entry
    end

  private
    def bank_entry
      @bank_entry ||= BankEntry.find(params[:id])
    end

    def new_bank_entry
      @new_bank_entry ||= BankEntry.new do |be|
        be.ammount_cents = 0
        be.date = Date.today
      end
    end

    def load_account_names
      @account_names = Account.order(:name).pluck(:name)
    end
  end
end
