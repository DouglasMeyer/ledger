class AccountEntry < ActiveRecord::Base
  belongs_to :bank_entry
  belongs_to :account

  def account_name
    account && account.name
  end
end
