class AccountEntry < ActiveRecord::Base
  validates :bank_entry, :account, :presence => true

  belongs_to :bank_entry
  belongs_to :account
  belongs_to :strategy

  accepts_nested_attributes_for :strategy

  scope :join_aggrigate_account_entries, ->{ joins(<<-ENDSQL) }
    LEFT OUTER JOIN (
      SELECT SUM(account_entries.ammount_cents) AS balance_cents,
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

  scope :with_balance, ->{ join_aggrigate_account_entries
                        .joins(:bank_entry)
                        .order("bank_entries.date DESC, bank_entries.id DESC")
                        .select("account_entries.*, aggrigate_account_entries.balance_cents") }

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
