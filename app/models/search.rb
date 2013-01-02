class Search
  include ActiveModel::AttributeMethods
  extend ActiveModel::Naming
  include ActiveModel::Conversion

  define_attribute_methods [ :name, :attribute, :operator, :ammount ]

  attr_accessor :name, :attribute, :operator, :ammount

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted? ; false ; end

  def self.attributes
    [ [ 'ammount remaining', :ammount_remaining ]
    ]
  end

  def self.operators
    [ 'is not equal to'
    ]
  end

  def ammount_cents
    (ammount.gsub(/,/, '').to_f * 100).round
  end

  def bank_entries
    return [] unless attribute.present? && operator.present? && ammount.present?
    BankEntry.select do |be|
      if operator == 'is not equal to'
        be.send(attribute) != ammount_cents
      end
    end
  end
end
