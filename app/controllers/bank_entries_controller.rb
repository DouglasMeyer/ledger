class BankEntriesController < ApplicationController
  def index
    @bank_entries = BankEntry.order("date DESC, id DESC")
    respond_to do |format|
      format.html
      format.json do
        @bank_entries = @bank_entries.limit(24)
        page = params[:page].to_i || 0
        if @bank_entries.offset(24 * (page+1)).any?
          response.headers['X-More'] = bank_entries_url(:page => page+1)
        end
        render :json => @bank_entries.offset(24 * page)
      end
    end
  end

  def show
    @bank_entry = BankEntry.find(params[:id])
    respond_to do |format|
      format.json { render :json => @bank_entry }
    end
  end
end
