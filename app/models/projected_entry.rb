class ProjectedEntry < ApplicationRecord
  include AccountName

  belongs_to :account

  validates :amount_cents, presence: true

  dollarify :amount_cents
end
