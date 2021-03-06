require 'rails_helper'

describe 'bank entries view', type: :feature do
  let(:bank_entries_page){ BankEntriesPage.new }

  it "loads bank entries" do
    30.times { BankEntry.make! amount_cents: 0 }
    bank_entries_page.load # ensure cache is up-to-date
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

  it "displays an expense bank entry" do
    be = BankEntry.make!(
      date: Date.new(2015, 1, 19),
      amount_cents: -10_00
    )
    ae = AccountEntry.make!(bank_entry: be, amount_cents: -10_00)
    account = ae.account.name
    bank_entries_page.load

    bank_entries_page.wait_for_bank_entries
    expect(bank_entries_page.bank_entries.first.text).to eq("2015-01-19 $-10.00 from #{account}")
  end

  it "displays an income bank entry" do
    be = BankEntry.make!(
      date: Date.new(2015, 1, 19),
      amount_cents: 10_00
    )
    ae = AccountEntry.make!(
      amount_cents: 10_00,
      bank_entry: be
    )
    account = ae.account.name
    bank_entries_page.load

    bank_entries_page.wait_for_bank_entries
    expect(bank_entries_page.bank_entries.first.text).to eq("2015-01-19 $10.00 to #{account}")
  end

  it "displays a transfer bank entry" do
    be = BankEntry.make!(
      date: Date.new(2015, 1, 19),
      amount_cents: 0
    )
    AccountEntry.make!(bank_entry: be, amount_cents: -10_00)
    AccountEntry.make!(bank_entry: be, amount_cents:  10_00)
    accounts = be.account_entries.map{ |ae| ae.account.name }
    bank_entries_page.load

    bank_entries_page.wait_for_bank_entries
    expect(bank_entries_page.bank_entries.first.text).to eq("2015-01-19 $10.00 from #{accounts.first} to #{accounts.last}")
  end

  # TODO: to test this properly, I would need the server to be down :(
  # it "caches fetched bank entries" do
  #   bank_entries_page.load
  #   expect(bank_entries_page).to have_bank_entries(count: 25)

  #   bank_entries_page.reload
  #   expect(bank_entries_page).to have_status(text: 'loading')
  #   expect(bank_entries_page).to have_bank_entries(count: 25)
  # end
end
