class Account < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validate :zero_balance_when_deleting

  has_many :entries, class_name: 'AccountEntry'
  belongs_to :strategy
  has_many :bank_entries, through: :entries
  has_many :account_entries

  scope :not_deleted, -> { where('deleted_at IS NULL') }
  scope :assets,      -> { where(asset: true) }
  scope :liabilities, -> { where(asset: false) }

  def balance_cents
    entries.pluck(:amount_cents).sum
  end

  def balance
    balance_cents / 100.0
  end

  def average_spent(average_over = 1)
    dates = bank_entries.order(:date).pluck(:date)
    return nil unless dates.any?
    months = (dates.first.months - dates.last.months)
    return nil if months.zero?
    spent = entries
            .joins(:bank_entry)
            .where('bank_entries.external_id IS NOT NULL')
            .where('bank_entries.amount_cents < 0')
            .pluck(:amount_cents).sum / 100.0
    spent * average_over / months
  end

  def as_json(options)
    (options[:methods] ||= []).push(:balance_cents, :class_name)
    super(options)
  end

  def class_name
    self.class.name
  end

  private

  def zero_balance_when_deleting
    errors.add(:balance_cents, :not_zero) unless balance_cents.zero? || deleted_at.blank?
  end
end
