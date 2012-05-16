class AccountsController < ApplicationController
  def index
    @accounts = Account.all
    respond_to do |format|
      format.html
      format.json { render :json => @accounts }
    end
  end

  def create
    account = Account.create! params[:account]
    respond_to do |format|
      format.json { render :json => account }
    end
  end
end
