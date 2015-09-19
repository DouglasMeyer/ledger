class BasePage < SitePrism::Page
  class NavigationSection < SitePrism::Section
    element :entry_counter, '.navigation__page.entries .count'
  end

  section :navigation, NavigationSection, '.navigation'
end
