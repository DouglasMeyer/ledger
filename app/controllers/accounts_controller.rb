class AccountsController < ApplicationController
  def index
    @accounts = Account.order(:position)
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
      format.json { render :json => @account }
    end
  rescue ActiveRecord::RecordInvalid
    render :new
  end

  def show
    @account = Account.find params[:id]
  end

  def update
    @account = Account.find params[:id]
    @account.update_attributes! params[:account]
    respond_to do |format|
      format.json { render :json => @account }
    end
  end

  def distribute
    @account = Account.find params[:id]
    @accounts = Account.scoped
  end
end
