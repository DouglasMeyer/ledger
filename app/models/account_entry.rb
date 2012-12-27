class AccountEntry < ActiveRecord::Base
  attr_accessible :account_name, :notes, :bank_entry_id, :ammount_cents, :ammount

  validates :bank_entry, :account, :presence => true

  belongs_to :bank_entry
  belongs_to :account

  def account_name
    account && account.name
  end
  def account_name= name
    self.account = Account.where(:name => name).first
  end

  def ammount
    (ammount_cents || 0) / 100.0
  end
  def ammount= val
    val = val.gsub(/,/, '').to_f if val.is_a? String
    self.ammount_cents = (val * 100).round
  end

  def as_json(options={})
    (options[:methods] ||= []).push(:account_name)
    super(options)
  end
end
