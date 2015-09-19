module V2
  class BankImportsController < BaseController
    def create
      BankImport.upload! params[:upload]
      redirect_to :root
    end
  end
end
