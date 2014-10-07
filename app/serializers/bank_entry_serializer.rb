class BankEntrySerializer < ActiveModel::Serializer
  attributes :id, :date, :notes, :description,
    :amountCents,
    :externalId,
    :createdAt,
    :updatedAt

  def amountCents
    object.amount_cents
  end

  def externalId
    object.external_id
  end

  def createdAt
    object.created_at
  end

  def updatedAt
    object.updated_at
  end
end
