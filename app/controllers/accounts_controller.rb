class AccountsController < ApplicationController
  def index
    @accounts = Account.scoped
    respond_to do |format|
      format.html
      format.json { render :json => @accounts }
    end
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new
    @account.update_attributes! params[:account]
    respond_to do |format|
      format.html { redirect_to :accounts }
      format.json { render :json => account }
    end
  rescue ActiveRecord::RecordInvalid
    render :new
  end
end
