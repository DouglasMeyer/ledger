class BankEntriesController < ApplicationController
  def index
    @bank_entries = BankEntry.scoped
    respond_to do |format|
      format.html
      format.json { render :json => @bank_entries }
    end
  end

  def show
    @bank_entry = BankEntry.find(params[:id])
    respond_to do |format|
      format.json { render :json => @bank_entry }
    end
  end
end
