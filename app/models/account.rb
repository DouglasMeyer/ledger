class Account < ActiveRecord::Base
  attr_accessible :name, :asset

  validates :name, :presence => true, :uniqueness => true

  has_many :entries, :class_name => 'AccountEntry'

  scope :assets,      where(:asset => true )
  scope :liabilities, where(:asset => false)

  def balance_cents
    entries.pluck(:ammount_cents).sum
  end
end
