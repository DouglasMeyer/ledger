require 'rails_helper'

describe 'bank entries view', type: :feature do
  before :each do
    30.times { BankEntry.make! }
  end

  let(:bank_entries_page){ BankEntriesPage.new }

  it "loads bank entries" do
    bank_entries_page.load

    expect(bank_entries_page).to have_bank_entries(count: 25)
  end

  it "caches fetched bank entries" do
    bank_entries_page.load
    expect(bank_entries_page).to have_bank_entries(count: 25)

    bank_entries_page.reload
    expect(bank_entries_page).to have_status(text: 'loading')
    expect(bank_entries_page.bank_entries.count).to be(25)
  end
end
