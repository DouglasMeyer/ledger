module V2
  class BankEntriesController < BaseController

    def index
      bank_entries # populate @bank_entries
    end

    def edit
      bank_entry # populate @bank_entry
      render layout: false
    end

    def update
      params[:bank_entry][:account_entries_attributes].delete(:new_account_entry)
      if bank_entry.update_attributes(params[:bank_entry])
        render bank_entry, layout: false
      else
        render :edit, layout: false
      end
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
