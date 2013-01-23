module V2
  class BankEntriesController < BaseController
    before_filter :load_account_names

    def index
      @within = {
        '1 week' => 1.week.ago,
        '2 weeks' => 2.weeks.ago,
        '1 month' => 1.month.ago,
        '2 months' => 2.months.ago,
        '4 months' => 4.months.ago,
        '6 months' => 6.months.ago,
        '1 year' => 1.year.ago
      }

      @bank_entries = bank_entries.includes(account_entries: :account)
      if (within = params[:within]).present? && @within[within]
        @bank_entries = bank_entries.where(date: (@within[within]...Time.now))
      end
      if (account_name = params[:account_name]).present?
        @bank_entries = bank_entries.where('accounts.name' => account_name)
      end
      if (needs_distribution = params[:needs_distribution]).present?
        @bank_entries = bank_entries.join_aggrigate_account_entries
          .where('bank_entries.ammount_cents != aggrigate_account_entries.ammount_cents OR aggrigate_account_entries.ammount_cents IS NULL')
      end
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

  private
    def bank_entries
      @bank_entries ||= BankEntry.order("bank_entries.date DESC, bank_entries.id DESC").limit(100)
    end
    def bank_entry
      @bank_entry ||= bank_entries.find(params[:id])
    end

    def load_account_names
      @account_names = Account.order(:name).pluck(:name)
    end
  end
end
