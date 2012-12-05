class BankEntry < ActiveRecord::Base
  has_many :account_entries

  def ammount
    ammount_cents / 100.0
  end

  def as_json(options={})
    (options[:methods] ||= []).push(:account_entries)
    super(options)
  end
end
