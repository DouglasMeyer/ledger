module V1
  class Api::V1::BankEntriesController < Api::V1::BaseController
    def index
      bank_entries = BankEntry.order("date DESC, id DESC").limit(24)
      page = params[:page].to_i || 0
      if bank_entries.offset(24 * (page+1)).any?
        response.headers['X-More'] = api_bank_entries_url(:page => page+1)
      end
      respond_with bank_entries.offset(24 * page)
    end

    def show
      respond_with BankEntry.find(params[:id])
    end
  end
end
