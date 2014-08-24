module V3
  class BankImportsController < BaseController

    def create
      BankImport.upload! params[:upload]
      redirect_to v3_bank_entries_path
    end

  end
end
