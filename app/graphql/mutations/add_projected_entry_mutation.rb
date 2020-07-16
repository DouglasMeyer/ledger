module Mutations
  class AddProjectedEntryMutation < GraphQL::Schema::RelayClassicMutation
    field :projected_entry, Types::ProjectedEntryType, null: false

    argument :account,      String, required: true
    argument :description,  String, required: false
    argument :amountCents,  Int,    required: true
    argument :rrule,        String, required: true

    def resolve(account:, description:, amount_cents:, rrule:)
      account = Account.where(name: account).first!
      projected_entry = ProjectedEntry.create!(
        account_id: account.id,
        description: description,
        amount_cents: amount_cents,
        rrule: rrule
      )
      { projected_entry: projected_entry }
    end
  end
end
