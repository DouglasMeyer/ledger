module V2
  class BankEntriesController < BaseController

    def index
      bank_entries # populate @bank_entries
    end

  private
    def bank_entries
      @bank_entries ||= BankEntry.order("date DESC, id DESC").limit(100)
    end
  end
end
