class BankEntry < ApplicationRecord
  attr_accessor :bank_balance_cents

  default_scope { order("bank_entries.date DESC, bank_entries.id DESC") }
  has_many :account_entries, inverse_of: :bank_entry, dependent: :restrict_with_error
  accepts_nested_attributes_for :account_entries, allow_destroy: true
  has_many :accounts, through: :account_entries

  validates :external_id, uniqueness: true, allow_nil: true
  validates :date, :amount_cents, presence: true
  validate :fields_from_bank_do_not_update

  scope :reverse_order, -> { order(:date, :id) }
  scope :join_aggrigate_bank_entries, ->{ joins(<<-ENDSQL) }
    LEFT OUTER JOIN (
      SELECT SUM(bank_entries.amount_cents) AS balance_cents,
             other_bes.id
      FROM bank_entries
      LEFT JOIN bank_entries AS other_bes
        ON other_bes.id >= bank_entries.id
      GROUP BY
        other_bes.id
    ) AS aggrigate_bank_entries
    ON aggrigate_bank_entries.id = bank_entries.id
  ENDSQL
  scope :with_balance, -> do
    query = join_aggrigate_bank_entries
    query.select_values = ["bank_entries.*", "aggrigate_bank_entries.balance_cents"]
    query
  end

  scope :join_aggrigate_account_entries, -> { joins(<<-ENDSQL) }
    LEFT OUTER JOIN (
      SELECT SUM(amount_cents) AS amount_cents,
             bank_entry_id
      FROM account_entries
      GROUP BY bank_entry_id
    ) AS aggrigate_account_entries
    ON aggrigate_account_entries.bank_entry_id = bank_entries.id
  ENDSQL

  scope :needs_distribution, -> { join_aggrigate_account_entries.where(<<-ENDSQL) }
    bank_entries.amount_cents != aggrigate_account_entries.amount_cents OR
    ( aggrigate_account_entries.amount_cents IS NULL AND
      bank_entries.amount_cents != 0 )
  ENDSQL

  scope :from_bank, -> { where("external_id IS NOT NULL") }
  def from_bank?
    external_id.present?
  end

  def amount
    amount_cents / 100.0 if amount_cents
  end

  def amount_remaining
    if amount_cents
      (amount_cents - account_entries.map(&:amount_cents).sum) / 100.0
    else
      0
    end
  end

  def as_json(options = {})
    (options[:methods] ||= []).push(:account_entries, :class_name)
    super(options)
  end

  def class_name
    self.class.name
  end

  private

  def fields_from_bank_do_not_update
    return if new_record?
    errors.add(:external_id, :immutable) if external_id_changed?
    return unless from_bank?
    errors.add(:date, :immutable) if date_changed?
    errors.add(:description, :immutable) if description_changed?
    errors.add(:amount_cents, :immutable) if amount_cents_changed?
  end
end
