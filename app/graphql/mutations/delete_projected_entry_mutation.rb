module Mutations
  class DeleteProjectedEntryMutation < GraphQL::Schema::RelayClassicMutation
    field :projected_entry, Types::ProjectedEntryType, null: false
    # field :id, 

    argument :id, Int, required: true

    def resolve(id:)
      projected_entry = ProjectedEntry.find(id);
      projected_entry.delete
      { projected_entry: projected_entry }
    end
  end
end
