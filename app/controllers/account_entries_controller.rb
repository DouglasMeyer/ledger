class AccountEntriesController < ApplicationController
  def index
    respond_to do |format|
      format.json { render :json => AccountEntries.all }
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
