class AccountEntry < ActiveRecord::Base
  include AccountName

  belongs_to :bank_entry, inverse_of: :account_entries
  belongs_to :account, inverse_of: :account_entries
  belongs_to :strategy

  #FIXME: This should be un-commented, but `BankEntry.create! account_entries_attributes: []` won't work.
  #validates :bank_entry, :account, :presence => true

  accepts_nested_attributes_for :strategy

  scope :join_aggrigate_account_entries, ->{ joins(<<-ENDSQL) }
    LEFT OUTER JOIN (
      SELECT SUM(account_entries.amount_cents) AS balance_cents,
             other_aes.id
      FROM account_entries
      LEFT JOIN bank_entries
        ON bank_entries.id = account_entries.bank_entry_id
      LEFT JOIN account_entries AS other_aes
        ON other_aes.account_id = account_entries.account_id
      LEFT JOIN bank_entries AS other_bes
        ON other_bes.id = other_aes.bank_entry_id
      WHERE bank_entries.id <= other_bes.id
      GROUP BY
        other_aes.id
    ) AS aggrigate_account_entries
    ON aggrigate_account_entries.id = account_entries.id
  ENDSQL

  scope :with_balance, ->{
    join_aggrigate_account_entries
      .joins(:bank_entry)
      .order('bank_entries.date DESC, bank_entries.id DESC')
      .select('account_entries.*, aggrigate_account_entries.balance_cents')
  }

  dollarify :amount_cents

  def as_json(options = {})
    (options[:methods] ||= []).push(:account_name, :class_name)
    super(options)
  end

  def class_name
    self.class.name
  end
end
