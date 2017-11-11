class Strategy < ApplicationRecord
  attr_accessor :amount

  has_one :account

  def self.types
    { fixed: 'Fixed',
      percent_of_income: '% of income',
      amount_per_month: '$ per month'
    }
  end

  def value(bank_entry = nil)
    case strategy_type
    when 'fixed'
      variable.to_f
    when 'percent_of_income'
      (bank_entry.amount_cents * (variable.to_f / 100)).round / 100.0
    when 'amount_per_month'
      # FIXME: I'm assuming income is twice a month
      variable.to_f / 2
    end
  end

  def as_json(options = {})
    (options[:methods] ||= []).push(:class_name)
    super(options)
  end

  def class_name
    self.class.name
  end
end
