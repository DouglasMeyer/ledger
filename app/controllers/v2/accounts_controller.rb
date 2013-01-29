module V2
  class AccountsController < BaseController

    class Accounts
      extend ActiveModel::Naming
      include ActiveModel::MassAssignmentSecurity
      include ActiveModel::Conversion
      #ActiveRecord::NestedAttributes::ClassMethods
      def initialize(attributes={})
        update_attributes(attributes)
      end
      def persisted?; true; end
      def id; ''; end

      attr_accessor :accounts
      delegate :assets, :liabilities, to: :accounts
      attr_accessible :accounts

      def update_attributes!(attributes)
        update_attributes(attributes)
        accounts.each &:save!
      end

      def accounts_attributes=(attributes)
        attributes.each do |_, values|
          accounts.detect{|a| a.id.to_s == values['id'] }.update_attributes values
        end
      end
    private
      def update_attributes(attributes)
        attributes.each do |name, value|
          send("#{name}=", value)
        end
      end
    end

    def index
      accounts # populate @accounts
    end

    def edit
      @edit_accounts = Accounts.new accounts: accounts # populate @accounts
    end

    def update
      @edit_accounts = Accounts.new accounts: accounts
      @edit_accounts.update_attributes! params[:accounts]
      redirect_to action: :index
    end

  private
    def accounts
      @accounts ||= Account.where("deleted_at IS NULL").order(:position)
    end
  end
end
