class Account < ActiveRecord::Base
  attr_accessible :name, :asset, :position, :deleted_at

  validates :name, :presence => true, :uniqueness => true
  validate :zero_balance_when_deleting

  has_many :entries, :class_name => 'AccountEntry'

  scope :assets,      where(:asset => true )
  scope :liabilities, where(:asset => false)

  def balance_cents
    entries.pluck(:ammount_cents).sum
  end

  def as_json(options)
    (options[:methods] ||= []).push(:balance_cents)
    super(options)
  end

private
  def zero_balance_when_deleting
    errors.add(:balance_cents, :not_zero) unless balance_cents.zero? || deleted_at.blank?
  end

end
