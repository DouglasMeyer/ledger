class EntriesController < ApplicationController
  def index
    @ledger = Ledger.find(params[:ledger_id])
  end
end
