class BankEntrySerializer < ActiveModel::Serializer
  attributes :id, :date, :notes, :description,
    ammountCents: :ammount_cents,
    externalId: :external_id,
    createdAt: :created_at,
    updatedAt: :updated_at
end
