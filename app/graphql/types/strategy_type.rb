class Types::BaseEnum < GraphQL::Schema::Enum
end

# app/graphql/types/media_category.rb
class Types::StrategyStrategyType < Types::BaseEnum
  value "fixed", "Set amount each income"
  value "percent_of_income", "Percentage of income"
  value "amount_per_month", "Set amount each month"
end

class Types::StrategyType < Types::BaseObject
  field :id, ID, null: false
  field :strategyType, Types::StrategyStrategyType, null: false
  field :variable, Int, null: true
  field :notes, String, null: true
end
