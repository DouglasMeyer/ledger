module V3
  class AccountsController < BaseController
    def show
      @account = Account.find(params[:id])
    end
  end
end
