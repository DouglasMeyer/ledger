class BasePage < SitePrism::Page

  class NavigationSection < SitePrism::Section
    element :entry_counter, '.navigation__page.entries .count'
  end

  section :navigation, NavigationSection, '.navigation'

  def page_action(title)
    Capybara.using_wait_time Capybara.default_wait_time do
      element_exists?(%Q|.page-actions > span[title="#{title}"]|)
    end
    find(%Q|.page-actions > span[title="#{title}"]|)
  end

  def reload
    page.execute_script('location.reload()')
  end
end
