module V2
  class BankEntriesController < BaseController
    before_filter :load_account_names

    def index
      @bank_entries = BankEntry.includes(account_entries: :account)
      respond_to do |format|
        format.html do
          @bank_entry_pages = @bank_entries.count / 25
          @bank_entries = @bank_entries.offset(params[:page].to_i * 25) if params[:page]
          @bank_entries = @bank_entries.limit(25)
          new_bank_entry.account_entries.build
        end
        format.csv { render content_type: 'text', text: @bank_entries.reverse_order.to_csv }
      end
    end

    def show
      render bank_entry
    end

    def edit
      bank_entry # populate @bank_entry
      @accounts = Account.not_deleted.order(:position)
      @distribute_as_income = bank_entry.account_entries.where("account_entries.strategy_id IS NOT NULL").any?
    end

    def update
      bank_entry.update_attributes! params.require(:bank_entry)
                                          .permit(account_entries_attributes: [
                                                    :id,
                                                    :account_name,
                                                    :account_id,
                                                    :ammount,
                                                    :_destroy ]
                                                 )
      if request.xhr?
        render bank_entry
      else
        redirect_to action: :index
      end
    end

    def create
      new_bank_entry.assign_attributes params.require(:bank_entry).permit(:date, :description)
      new_bank_entry.save!

      new_bank_entry.update_attributes!(params.require(:bank_entry).permit(account_entries_attributes: [
        :account_name, :ammount
      ]))
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
      @account_names = Account.not_deleted.order(:name).pluck(:name)
    end
  end
end
