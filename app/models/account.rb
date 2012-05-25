class Account < ActiveRecord::Base
  attr_accessible :name

  has_many :entries, :class_name => 'AccountEntry'

  validates :name, :presence => true, :uniqueness => true

  def balance_cents
    entries.pluck(:ammount_cents).sum
  end
end
