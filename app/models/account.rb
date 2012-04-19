class Account < ActiveRecord::Base
  has_many :entries
end
