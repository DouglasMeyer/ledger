module V3
  class BankImportsController < BaseController
    def create
      BankImport.upload! params[:upload]
      AutocompleteBankEntryJob.perform_later(
        BankEntry.needs_distribution.pluck(:id)
      )
      redirect_to v3_root_path(anchor: '/entries')
    end
  end
end
