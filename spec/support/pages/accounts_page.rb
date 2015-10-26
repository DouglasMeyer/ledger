class AccountsPage < SitePrism::Page
  class AccountTypeLine < SitePrism::Section
    def name
      account_name = root_element.all('a')
      if account_name.any?
        account_name.first.text
      else
        root_element.text
      end
    end
  end

  set_url '/v3#/accounts'
  set_url_matcher %r{/v3#/accounts$}

  sections :asset_lines,     AccountTypeLine,
    "[ng-controller='AccountsCtrl'] > *:nth-child(1) .m-line"
  sections :liability_lines, AccountTypeLine,
    "[ng-controller='AccountsCtrl'] > *:nth-child(2) .m-line"
end
