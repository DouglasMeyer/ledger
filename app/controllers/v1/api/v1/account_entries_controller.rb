module V1
  class Api::V1::AccountEntriesController < Api::V1::BaseController
    def index
      account_entries = AccountEntry.scoped
      account_entries = account_entries.where(:bank_entry_id => params[:bank_entry]) if params[:bank_entry]
      respond_with account_entries
    end

    def create
      respond_with AccountEntry.create(params[:account_entry])
    end

    def update
      respond_with AccountEntry.update(params[:id], params[:account_entry])
    end

    def destroy
      respond_with AccountEntry.destroy(params[:id])
    end
  end
end
