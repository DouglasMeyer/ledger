class Ledger < ActiveRecord::Base
  has_many :entries
  has_many :accounts

  def balance
    entries.pluck(:ammount).sum
  end
end
