class Account < ActiveRecord::Base
  has_many :entries

  def balance
    entries.pluck(:ammount).sum
  end
end
