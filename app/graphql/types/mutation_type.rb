module Types
  class MutationType < BaseObject
    field :deleteProjectedEntryMutation, mutation: Mutations::DeleteProjectedEntryMutation
    field :addProjectedEntryMutation, mutation: Mutations::AddProjectedEntryMutation
    field :updateProjectedEntryMutation, mutation: Mutations::UpdateProjectedEntryMutation
  end
end
