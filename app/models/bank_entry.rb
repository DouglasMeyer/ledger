class BankEntry < ActiveRecord::Base
  attr_accessor :bank_balance_cents

  default_scope { order("bank_entries.date DESC, bank_entries.id DESC") }
  has_many :account_entries, dependent: :restrict_with_error
  accepts_nested_attributes_for :account_entries, allow_destroy: true

  validates :external_id, uniqueness: true, allow_nil: true
  validates :date, :ammount_cents, :presence => true
  validate :fields_from_bank_do_not_update

  scope :reverse_order, -> { order(:date, :id) }
  scope :join_aggrigate_bank_entries, ->{ joins(<<-ENDSQL) }
    LEFT OUTER JOIN (
      SELECT SUM(bank_entries.ammount_cents) AS balance_cents,
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
      SELECT SUM(ammount_cents) AS ammount_cents,
             bank_entry_id
      FROM account_entries
      GROUP BY bank_entry_id
    ) AS aggrigate_account_entries
    ON aggrigate_account_entries.bank_entry_id = bank_entries.id
  ENDSQL

  scope :needs_distribution, -> { join_aggrigate_account_entries.where(<<-ENDSQL) }
    bank_entries.ammount_cents != aggrigate_account_entries.ammount_cents OR
    ( aggrigate_account_entries.ammount_cents IS NULL AND
      bank_entries.ammount_cents != 0 )
  ENDSQL

  scope :from_bank, -> { where("external_id IS NOT NULL") }
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

  def self.to_csv
    CSV.generate do |csv|
      csv << [ 'Date', 'Check #', 'Description', 'Debit', 'Credit', 'Status', 'Balance', 'id', 'Category' ]
      all.each do |bank_entry|
        debit = -bank_entry.ammount if bank_entry.ammount < 0
        credit = bank_entry.ammount if bank_entry.ammount > 0
        account_name = ''
        if bank_entry.account_entries.length == 1
          account_entry = bank_entry.account_entries.first
          debit = -account_entry.ammount if account_entry.ammount < 0
          credit = account_entry.ammount if account_entry.ammount > 0
          account_name = account_entry.account_name
        end
        csv << [ bank_entry.date.strftime('%m/%d/%Y'), bank_entry.notes, bank_entry.description, debit, credit, '', '$', bank_entry.external_id, account_name ]
        if bank_entry.account_entries.length > 1
          bank_entry.account_entries.each do |account_entry|
            csv << [ '', '', '',
              (-account_entry.ammount if account_entry.ammount < 0),
              (account_entry.ammount if account_entry.ammount > 0),
              '', '', '', account_entry.account_name
            ]
          end
        end
      end
    end
  end

private
  def fields_from_bank_do_not_update
    return if new_record?
    errors.add(:external_id, :immutable) if external_id_changed?
    return unless from_bank?
    errors.add(:date, :immutable) if date_changed?
    errors.add(:description, :immutable) if description_changed?
    errors.add(:ammount_cents, :immutable) if ammount_cents_changed?
  end

end
