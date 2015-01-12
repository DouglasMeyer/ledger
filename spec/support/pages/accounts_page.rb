class AccountsPage < SitePrism::Page
  class AccountTypeLine < SitePrism::Section
    def name
      root_element.find('h3, a').text
    end
  end

  set_url '/v3#/accounts'
  set_url_matcher /\/v3#\/accounts/

  sections :asset_lines,     AccountTypeLine, ".accounts-table__assets li"
  sections :liability_lines, AccountTypeLine, ".accounts-table__liabilities li"
end
