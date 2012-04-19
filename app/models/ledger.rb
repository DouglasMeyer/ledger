class Ledger < ActiveRecord::Base
  has_many :entries
  has_many :accounts
end
