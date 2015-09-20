class ProjectedEntrySerializer < ActiveModel::Serializer
  attributes :id, :description, :amount_cents, :rrule,
             :account_name
end
