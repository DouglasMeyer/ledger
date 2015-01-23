class ForecastPage < BasePage
  class ProjectedEntrySection < SitePrism::Section
    element :date,        "input[ng-model='entry.date']"
    element :account,     "input[ng-model='entry.projectedEntry.account']"
    element :amount,      "input[ng-model='entry.projectedEntry.amountCents']"
    element :description, "input[ng-model='entry.projectedEntry.description']"
    element :frequency,   "select[ng-model='entry.frequency']"

    def set_frequency(text)
      frequency.find(:xpath, "option[normalize-space(text())='#{text}']").select_option
    end

    def save
      root_element.find('.button--primary').click
    end
  end

  set_url '/v3#/forecast'
  set_url_matcher /\/v3#\/forecast$/

  sections :projected_entries, ProjectedEntrySection, ".table__rows"
end
