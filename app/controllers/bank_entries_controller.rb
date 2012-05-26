class BankEntriesController < ApplicationController
  def index
    @bank_entries = BankEntry.scoped
    respond_to do |format|
      format.html
      format.json { render :json => @bank_entries }
    end
  end
end
