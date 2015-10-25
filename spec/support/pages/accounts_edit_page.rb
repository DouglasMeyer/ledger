class AccountsEditPage < SitePrism::Page
  class AccountSection < SitePrism::Section
    def name
      root_element.find('input[ng-model="account.name"]').value
    end
  end

  class CategorySection < SitePrism::Section
    def name
      root_element.find('h4 > input').value
    end

    sections :accounts, AccountSection, '[ng-repeat^="account in accounts"]'

    def add_account(account_name)
      root_element.find('input[placeholder="add account"]')
        .set(account_name)
    end
  end

  set_url '/v3#/accounts/edit'
  set_url_matcher /\/v3#\/accounts\/edit$/

  sections :asset_categories,     CategorySection, '.m-accountType:nth-child(1) .m-category'
  sections :liability_categories, CategorySection, '.m-accountType:nth-child(2) .m-category'

  ### Actions

  def save
    find('button[ng-click="save()"]').click
  end

  def add_category(account_type, category_name)
    add_category_input = if account_type == :asset
                           find('.m-accountType:nth-child(1) input[placeholder="add category"]')
                         else
                           find('.m-accountType:nth-child(2) input[placeholder="add category"]')
                         end
    add_category_input.set(category_name)
    add_category_input.trigger('blur')
  end

  def add_account(account_type, category_name, account_name)
    categories = (account_type == :asset ? asset_categories : liability_categories)
    category = categories.detect { |c| c.name == category_name }
    if category
      category.add_account(account_name)
    else
      throw "category #{category_name.inspect} not one of #{categories.map(&:name).inspect}"
    end
  end
end
