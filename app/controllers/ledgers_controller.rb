class LedgersController < ApplicationController
  def index
    @ledgers = Ledger.all
  end

  def show
    @ledger = Ledger.find(params[:id])
  end
end
