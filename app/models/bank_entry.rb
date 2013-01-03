class BankEntry < ActiveRecord::Base
  has_many :account_entries
  accepts_nested_attributes_for :account_entries, allow_destroy: true

  attr_accessible :account_entries_attributes

  scope :join_aggrigate_account_entries, joins(<<-ENDSQL)
    LEFT OUTER JOIN (
      SELECT SUM(ammount_cents) AS ammount_cents,
             bank_entry_id
      FROM account_entries
      GROUP BY bank_entry_id
    ) AS aggrigate_account_entries
    ON aggrigate_account_entries.bank_entry_id = bank_entries.id
  ENDSQL

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
