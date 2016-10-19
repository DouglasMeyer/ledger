class User < ApplicationRecord
  validates :provider, :email, :ledger, presence: true
end
