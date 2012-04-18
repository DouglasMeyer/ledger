class Entry < ActiveRecord::Base
  belongs_to :ledger
  belongs_to :bank_entry, :class_name => 'Entry'
end
