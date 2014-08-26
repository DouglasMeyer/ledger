module V3
  class BankImportsController < BaseController

    def create
      BankImport.upload! params[:upload]
      redirect_to v3_root_path(anchor: '/entries')
    end

  end
end
