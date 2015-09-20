require 'rails_helper'

describe 'forecast view', type: :feature do
  let(:forecast_page){ ForecastPage.new }

  it "shows projected entries" do
    ProjectedEntry.make!
    forecast_page.load

    forecast_page.wait_for_projected_entries
    expect(forecast_page.projected_entries.count).to be_between(10, 11)
    forecast_page.projected_entries.each do |projected_entry|
      expect(projected_entry).to have_text('Mon')
    end
  end

  describe "creating" do
    let!(:account_name){ Account.make!.name }

    before do
      forecast_page.load
      forecast_page.page_action('Add Projection').click
      forecast_page.wait_for_projected_entries(count: 1)
    end

    it "creates" do
      forecast_page.projected_entries.first.tap do |pe|
        pe.date.set Date.today.to_s
        pe.set_account account_name
        pe.amount.set '56.78'
        pe.description.set 'something'
        pe.set_frequency 'Weekly'
        pe.save
      end

      expect(forecast_page).to have_projected_entries(count: 11)
    end

    it "is cancelable" do
      forecast_page.projected_entries.first.tap do |pe|
        pe.date.set Date.today.to_s
        pe.account.set account_name
        pe.amount.set '56.78'
        pe.cancel
      end

      expect(forecast_page).to have_projected_entries(count: 0)
    end
  end

  describe "editing" do
    let(:account_name){ Account.make!.name }

    before do
      ProjectedEntry.make!
      forecast_page.load
      forecast_page.wait_for_projected_entries
      forecast_page.projected_entries.first.click
    end

    it "edits" do
      forecast_page.projected_entries.first.tap do |pe|
        pe.date.set Date.today.to_s
        pe.account.set account_name
        pe.amount.set '56.78'
        pe.description.set 'something'
        pe.set_frequency 'Once'
        pe.save
      end

      expect(forecast_page).to have_projected_entries(count: 1)
    end

    it "is cancelable" do
      forecast_page.projected_entries.first.tap do |pe|
        pe.description.set 'crazy'
        pe.cancel
      end

      forecast_page.wait_for_projected_entries
      expect(forecast_page.projected_entries.count).to be_between(10, 11)
      expect(forecast_page.projected_entries.first).not_to have_text('crazy')
    end
  end
end
