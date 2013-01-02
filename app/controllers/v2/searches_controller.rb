module V2
  class SearchesController < BaseController

    def new
      @search = Search.new
    end

    def create
      @search = Search.new params[:search]
      @account_names = Account.order(:name).pluck(:name)
      render action: :new
    end

  end
end
