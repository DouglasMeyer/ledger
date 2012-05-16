class BankEntriesController < ApplicationController
  def index
    @bank_entries = BankEntry.all
    respond_to do |format|
      format.html
    end
  end
end
