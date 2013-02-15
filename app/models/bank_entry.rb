class BankEntry < ActiveRecord::Base
  default_scope order("bank_entries.date DESC, bank_entries.id DESC")
  has_many :account_entries
  accepts_nested_attributes_for :account_entries, allow_destroy: true

  attr_accessible :account_entries_attributes
  attr_accessible :date, :description, :account_entries_attributes, :ammount_cents, as: :creator

  scope :join_aggrigate_account_entries, joins(<<-ENDSQL)
    LEFT OUTER JOIN (
      SELECT SUM(ammount_cents) AS ammount_cents,
             bank_entry_id
      FROM account_entries
      GROUP BY bank_entry_id
    ) AS aggrigate_account_entries
    ON aggrigate_account_entries.bank_entry_id = bank_entries.id
  ENDSQL

  scope :needs_distribution, join_aggrigate_account_entries.where(<<-ENDSQL)
    bank_entries.ammount_cents != aggrigate_account_entries.ammount_cents OR
    ( aggrigate_account_entries.ammount_cents IS NULL AND
      bank_entries.ammount_cents != 0 )
  ENDSQL

  scope :from_bank, where("external_id IS NOT NULL")
  def from_bank?
    external_id.present?
  end

  def ammount
    ammount_cents / 100.0 if ammount_cents
  end

  def ammount_remaining
    if ammount_cents
      (ammount_cents - account_entries.map(&:ammount_cents).sum) / 100.0
    else
      0
    end
  end

  def as_json(options={})
    (options[:methods] ||= []).push(:account_entries)
    super(options)
  end
end
