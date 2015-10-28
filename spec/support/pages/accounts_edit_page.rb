class AccountsEditPage < SitePrism::Page
  class AccountSection < SitePrism::Section
    def name
      root_element.find('input[ng-model="account.name"]').value
    end
  end

  class CategorySection < SitePrism::Section
    def name
      root_element.find("h4 > input").value
    end

    sections :accounts, AccountSection, '[ng-repeat^="account in accounts"]'

    def add_account(account_name)
      root_element.find('input[placeholder="add account"]')
        .set(account_name)
    end
  end

  set_url '/v3#/accounts/edit'
  set_url_matcher %r{/v3#/accounts/edit$}

  sections :asset_categories,     CategorySection,
    ".m-accountType:nth-child(1) .m-category"
  sections :liability_categories, CategorySection,
    ".m-accountType:nth-child(2) .m-category"

  ### Actions

  def save
    find('button[ng-click="save()"]').click
  end

  def add_category(account_type, category_name)
    find(
      ".m-accountType:nth-child(#{account_type == :asset ? 1 : 2})" \
      ' input[placeholder="add category"]'
    ).instance_eval do
      set category_name
      trigger "blur"
    end
  end

  def add_account(account_type, category_name, account_name)
    category(account_type, category_name)
      .add_account(account_name)
  end

  private

  def categories(account_type)
    if account_type == :asset
      asset_categories
    elsif account_type == :liability
      liability_categories
    else
      fail ArgumentError, "#{account_type.inspect} not a valid account_type"
    end
  end

  def category(account_type, category_name)
    categories = categories(account_type)
    category = categories.detect { |c| c.name == category_name }
    unless category
      fail ArgumentError,
        "category #{category_name.inspect} " \
        "not one of #{categories.map(&:name).inspect}"
    end
    category
  end
end
