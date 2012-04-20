class Entry < ActiveRecord::Base
  belongs_to :ledger
  belongs_to :bank_entry, :class_name => 'Entry'
  belongs_to :account

  validates :bank_entry, :account, :presence => true, :unless => :is_bank_entry?

  def account_name
    account && account.name
  end

private
  def is_bank_entry?
    ledger.bank?
  end

end
