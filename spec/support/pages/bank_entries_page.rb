class BankEntriesPage < BasePage
  class AccountEntrySection < SitePrism::Section
    element :amount,        ".table__cell--amount"
    element :amount_field,  ".table__cell--amount input"
    element :account,       ".table__cell--account"
    element :account_field, ".table__cell--account select"
  end

  class BankEntrySection < SitePrism::Section
    sections :account_entries, AccountEntrySection,
      ".table__row[ng-repeat='accountEntry in entry.accountEntries']"
    element :close_button,  "button", text: "close"
    element :save_button,   "button", text: "save"
    element :cancel_button, "button", text: "cancel"
    element :saving_message, "span",  text: "saving..."

    delegate :click, :text, to: :root_element
  end

  set_url '/v3#/entries'
  set_url_matcher %r{/v3#/entries$}

  sections :bank_entries, BankEntrySection, ".table__rows"

  elements :status, ".navigation__status .list__item"
end
