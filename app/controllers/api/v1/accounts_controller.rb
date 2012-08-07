class Api::V1::AccountsController < Api::V1::BaseController
  def index
    respond_with accounts
  end

  def create
    respond_with accounts.create(params[:account])
  end

  def update
    account.update_attributes!(params[:account])
    respond_with account
  end

  def destroy
    account.update_attributes!(:deleted_at => Time.now)
    respond_with account
  end

private
  def accounts
    @accounts ||= Account.where("deleted_at IS NULL").order(:position)
  end
  def account
    @account ||= accounts.find(params[:id])
  end
end
