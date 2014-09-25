require 'rails_helper'

class BankEntriesPage < SitePrism::Page
  set_url '/v3#/entries'
  set_url_matcher /\/v3#\/entries/

  elements :bank_entries, ".table__rows"
  elements :status, ".navigation__status .list__item"

  def reload
    page.execute_script('location.reload()')
  end
end

feature 'bank entries view' do
  background do
    30.times { BankEntry.make! }
  end

  let(:bank_entries_page){ BankEntriesPage.new }

  scenario "loads bank entries" do
    bank_entries_page.load

    expect(bank_entries_page).to have_bank_entries(count: 25)
  end

  scenario "caches fetched bank entries" do
    bank_entries_page.load
    expect(bank_entries_page).to have_bank_entries(count: 25)

    bank_entries_page.reload
    expect(bank_entries_page).to have_status(text: 'loading')
    expect(bank_entries_page.bank_entries.count).to be(25)
  end
end
