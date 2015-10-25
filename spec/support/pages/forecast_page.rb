class ForecastPage < BasePage
  class ProjectedEntrySection < SitePrism::Section
    element :date,        "input[ng-model$='.date']"
    element :account,     "select[ng-model$='.accountName']"
    element :amount,      "input[ng-model$='.amountCents']"
    element :description, "input[ng-model$='.description']"
    element :frequency,   "select[ng-model$='.frequency']"

    def set_account(text)
      account.find(:xpath, "option[normalize-space(text())='#{text}']").select_option
    end

    def set_frequency(text)
      frequency.find(:xpath, "option[normalize-space(text())='#{text}']").select_option
    end

    def save
      root_element.find('button', text: 'Save').click
    end

    def cancel
      root_element.find('button', text: 'cancel').click
    end

    delegate :click, to: :root_element
  end

  set_url '/v3#/forecast'
  set_url_matcher /\/v3#\/forecast$/

  sections :projected_entries, ProjectedEntrySection, ".table__rows"
end
