class User < ActiveRecord::Base
  validates :provider, :email, :ledger, presence: true
end
