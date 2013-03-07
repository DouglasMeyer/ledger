class Strategy < ActiveRecord::Base
  attr_accessor :ammount

  has_one :account

  def self.types
    { fixed: 'Fixed',
      percent_of_income: '% of income',
      ammount_per_month: '$ per month'
    }
  end

  def value(bank_entry=nil)
    case strategy_type
    when 'fixed'
      variable.to_f
    when 'percent_of_income'
      (bank_entry.ammount_cents * (variable.to_f / 100)).round / 100.0
    when 'ammount_per_month'
      #FIXME: I'm assuming income is twice a month
      variable.to_f / 2
    end
  end

end
