class Account < ActiveRecord::Base
  attr_accessible :name

  has_many :entries, :class_name => 'AccountEntries'

  validates_uniqueness_of :name

  def balance
    entries.pluck(:ammount).sum
  end
end
