module V2
  class AccountsController < BaseController

    def index
      accounts # populate @accounts
    end

  private
    def accounts
      @accounts ||= Account.where("deleted_at IS NULL").order(:position)
    end
  end
end
