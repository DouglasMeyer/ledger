require 'rails_helper'

describe 'bank entries view', type: :feature do
  let(:bank_entries_page){ BankEntriesPage.new }

  it "loads bank entries" do
    30.times { BankEntry.make! amount_cents: 0 }
    bank_entries_page.load

    expect(bank_entries_page).to have_bank_entries(count: 25)
  end

  describe "a bank entry that needs distribution" do
    it "is reflected in the entry counter" do
      30.times { BankEntry.make! amount_cents: 10 }
      bank_entries_page.load

      expect(bank_entries_page.navigation).to have_entry_counter(text: '30')
    end
  end

  #TODO: to test this properly, I would need the server to be down :(
  #it "caches fetched bank entries" do
  #  bank_entries_page.load
  #  expect(bank_entries_page).to have_bank_entries(count: 25)

  #  bank_entries_page.reload
  #  expect(bank_entries_page).to have_status(text: 'loading')
  #  expect(bank_entries_page).to have_bank_entries(count: 25)
  #end
end
