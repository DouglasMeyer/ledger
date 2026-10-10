class AutocompleteBankEntryJob < ApplicationJob
  queue_as :default

  def perform(bank_entry_ids)
    APL::BankEntryAutocomplete_v1.read(ids: bank_entry_ids)
  end
end
