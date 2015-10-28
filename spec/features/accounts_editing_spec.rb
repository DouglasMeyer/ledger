require "rails_helper"

describe "accounts editing view", type: :feature do
  let(:accounts_edit_page) { AccountsEditPage.new }
  let(:accounts_page) { AccountsPage.new }

  matcher :have_account_hash do |expected_account_hash|
    def actual
      super.each_with_object({}) do |category, h|
        h[category.name] = category.accounts.map(&:name)
      end
    end

    match do
      actual == expected_account_hash
    end
    diffable
  end

  it "shows accounts ordered by position" do
    asset_names = [
      Account.make!(:asset, category: "save", position: 2),
      Account.make!(:asset, category: "save", position: 1)
    ].reverse.map(&:name)

    liability_names = [
      Account.make!(:liability, category: "bills", position: 2),
      Account.make!(:liability, category: "bills", position: 1)
    ].reverse.map(&:name)

    accounts_edit_page.load
    accounts_edit_page.wait_for_asset_categories

    expect(accounts_edit_page.asset_categories.count).to eq(1)
    expect(accounts_edit_page.liability_categories.count).to eq(1)

    expect(accounts_edit_page.asset_categories).to have_account_hash(
      "save" => asset_names
    )
    expect(accounts_edit_page.liability_categories).to have_account_hash(
      "bills" => liability_names
    )
  end

  it "can create categories and accounts" do
    accounts_edit_page.load

    accounts_edit_page.add_category :asset, "asset category"
    accounts_edit_page.add_account :asset, "asset category",
      "asset account for asset category"
    accounts_edit_page.save
    expect(accounts_page).to be_displayed

    expect(accounts_page).to have_asset_lines(count: 3)
    expect(accounts_page.asset_lines.map(&:name))
      .to eq([
        "asset category",
        "asset category account",
        "asset account for asset category"
      ])
    expect(accounts_page).to have_liability_lines(count: 0)
  end
end
