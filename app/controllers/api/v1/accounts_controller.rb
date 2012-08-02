class Api::V1::AccountsController < Api::V1::BaseController
  def index
    respond_with Account.order(:position)
  end

  def create
    respond_with Account.create(params[:account])
  end

  def update
    respond_with Account.update(params[:id], params[:account])
  end
end
