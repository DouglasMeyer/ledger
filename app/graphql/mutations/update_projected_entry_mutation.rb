module Mutations
  class UpdateProjectedEntryMutation < GraphQL::Schema::RelayClassicMutation
    field :projected_entry, Types::ProjectedEntryType, null: false

    argument :id,           ID,     required: true
    argument :account,      String, required: true
    argument :description,  String, required: false
    argument :amountCents,  Int,    required: true
    argument :rrule,        String, required: true

    def resolve(id:, account:, description:, amount_cents:, rrule:)
      account = Account.where(name: account).first!
      projected_entry = ProjectedEntry.find!(id)
      projected_entry.update!(
        account_id: account.id,
        description: description,
        amount_cents: amount_cents,
        rrule: rrule
      )
      { projected_entry: projected_entry }
    end
  end
end
