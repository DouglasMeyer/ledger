module V2
  class BankEntriesController < BaseController
    before_filter :load_account_names

    def index
      @bank_entries = bank_entries.includes(account_entries: :account)
    end

    def edit
      #bank_entry # populate @bank_entry
      #Account.where("deleted_at IS NULL").each do |account|
      #  bank_entry.account_entries.where(account_id: account).tap do |ae|
      #    ae.build unless ae.any?
      #  end
      #end
      #@assets, @liabilities = bank_entry.account_entries.sort_by{|ae| ae.account.position }.partition do |account_entry|
      #  account_entry.account.asset?
      #end

      @assets, @liabilities = [], []
      Account.where("deleted_at IS NULL").order(:position).each do |account|
        aes = bank_entry.account_entries.where(account_id: account.id).all
        aes << bank_entry.account_entries.build({ account_id: account.id }, without_protection: true) unless aes.any?
        aes.first.ammount_cents
        aes[1..-1].each do |ae|
          #ae._destroy = true
          aes.first.ammount_cents += ae.ammount_cents
        end
        if account.asset?
          @assets += aes
        else
          @liabilities += aes
        end
      end
      @assets.each{|a| puts a.account.name }
      @liabilities.each{|a| puts a.account.name }
    end

    def update
      bank_entry.update_attributes!(params[:bank_entry])
      render bank_entry
    end

  private
    def bank_entries
      @bank_entries ||= BankEntry.order("date DESC, id DESC").limit(100)
    end
    def bank_entry
      @bank_entry ||= bank_entries.find(params[:id])
    end

    def load_account_names
      @account_names = Account.order(:name).pluck(:name)
    end
  end
end
