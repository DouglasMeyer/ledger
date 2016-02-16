class User < ActiveRecord::Base
  validates :provider, :email, presence: true
end
