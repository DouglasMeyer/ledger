module V3
  class AccountsController < BaseController

    class Accounts
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      def initialize(attributes={})
        assign_attributes(attributes)
      end
      def id; ''; end

      attr_accessor :accounts
      delegate :assets, :liabilities, to: :accounts

      def update_attributes!(attributes)
        assign_attributes(attributes)
        accounts.each &:save!
      end

      def accounts_attributes=(attributes)
        attributes.each do |_, values|
          id = values.delete(:id)
          destroy = values.delete(:_destroy)
          account = accounts.detect{|a| a.id.to_s == id } || Account.new
          if destroy == '1'
            next if account.new_record?
            values = { deleted_at: Time.now }
          end
          account.update_attributes! values
        end
      end
    private
      def assign_attributes(attributes)
        attributes.each do |name, value|
          send("#{name}=", value)
        end
      end
    end

    def index
      accounts # populate @accounts
    end

    def show
      @account = Account.find(params[:id])
    end

    def edit
      @edit_accounts = Accounts.new accounts: accounts # populate @accounts
    end

    def update # update all accounts
      @edit_accounts = Accounts.new accounts: accounts
      @edit_accounts.update_attributes! params[:accounts]
      redirect_to action: :index
    end

  private
    def accounts
      @accounts ||= Account.not_deleted.order(:position)
    end

    def accounts_attributes
      params.permit(accounts: [ :name, :asset, :category, :position ]) # Deleted
    end
  end
end
