require 'rails_helper'

describe 'accounts editing view', type: :feature do
  let(:accounts_edit_page){ AccountsEditPage.new }
  let(:accounts_page){ AccountsPage.new }

  it "shows accounts ordered by position" do
    Account.make!(asset: true, name: 'asset 2', category: 'save', position: 2)
    Account.make!(asset: true, name: 'asset 1', category: 'save', position: 1)

    Account.make!(asset: false, name: 'liability 2', category: 'bills', position: 2)
    Account.make!(asset: false, name: 'liability 1', category: 'bills', position: 1)

    accounts_edit_page.load
    accounts_edit_page.wait_for_asset_categories

    expect(accounts_edit_page.asset_categories.count).to eq(1)
    expect(accounts_edit_page.liability_categories.count).to eq(1)

    assets = accounts_edit_page.asset_categories.each_with_object({}) do |category, acc|
      acc[category.name] = category.accounts.map(&:name)
    end
    expect(assets).to eq('save' => [ 'asset 1', 'asset 2' ])
    liabilities = accounts_edit_page.liability_categories.each_with_object({}) do |category, acc|
      acc[category.name] = category.accounts.map(&:name)
    end
    expect(liabilities).to eq('bills' => [ 'liability 1', 'liability 2' ])
  end

  it "can create categories and accounts" do
    accounts_edit_page.load

    accounts_edit_page.add_category :asset, 'asset category'
    accounts_edit_page.add_account :asset, 'asset category', 'asset account for asset category'
    accounts_edit_page.save
    expect(accounts_page).to be_displayed

    expect(accounts_page).to have_asset_lines(count: 3)
    expect(accounts_page.asset_lines.map(&:name)).to eq(['asset category', 'asset category account', 'asset account for asset category'])
    expect(accounts_page).to have_liability_lines(count: 0)
  end

end
