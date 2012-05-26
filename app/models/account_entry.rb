class AccountEntry < ActiveRecord::Base
  attr_accessible :account_name, :notes, :bank_entry_id, :ammount_cents

  validates :bank_entry, :account, :presence => true

  belongs_to :bank_entry
  belongs_to :account

  def account_name
    account && account.name
  end
  def account_name= name
    self.account = Account.where(:name => name).first
  end

  def as_json(options)
    json = super
    json[:account_name] = account_name
    json
  end
end
