class Ledger < ActiveRecord::Base
  has_many :entries
end
