require 'rails_helper'

describe 'forecast view', type: :feature do
  let(:forecast_page){ ForecastPage.new }

  it "shows projected entries" do
    ProjectedEntry.make!(
      rrule: "FREQ=WEEKLY;DTSTART=20140120T060000Z"
    )
    forecast_page.load

    expect(forecast_page).to have_projected_entries(count: 11)
    forecast_page.projected_entries.each do |projected_entry|
      expect(projected_entry).to have_text('Mon')
    end
  end

  describe "creating" do
    it "creates" do
      account_name = Account.make!.name
      forecast_page.load
      forecast_page.page_action('Add Projection').click

      expect(forecast_page).to have_projected_entries(count: 1)
      forecast_page.projected_entries.first.tap do |pe|
        pe.date.set Date.today.to_s
        pe.account.set account_name
        pe.amount.set '56.78'
        pe.description.set 'something'
        pe.set_frequency 'Weekly'
        pe.save
      end

      expect(forecast_page).to have_projected_entries(count: 11)
    end
  end
end
