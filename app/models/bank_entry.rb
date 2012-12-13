class BankEntry < ActiveRecord::Base
  has_many :account_entries
  accepts_nested_attributes_for :account_entries, allow_destroy: true

  attr_accessible :account_entries_attributes

  def ammount
    ammount_cents / 100.0
  end

  def ammount_remaining
    (ammount_cents - account_entries.map(&:ammount_cents).sum) / 100.0
  end

  def as_json(options={})
    (options[:methods] ||= []).push(:account_entries)
    super(options)
  end
end
