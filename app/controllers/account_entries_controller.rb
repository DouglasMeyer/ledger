class AccountEntriesController < ApplicationController
  def index
    entries = AccountEntry.scoped
    entries = entries.where(:bank_entry_id => params[:bank_entry]) if params[:bank_entry]
    respond_to do |format|
      format.json { render :json => entries }
    end
  end

  def create
    account_entry = AccountEntry.create! params[:account_entry]
    respond_to do |format|
      format.json { render :json => account_entry }
    end
  end

  def destroy
    account_entry = AccountEntry.find(params[:id])
    account_entry.destroy
    respond_to do |format|
      format.json { render :nothing => true }
    end
  end
end
