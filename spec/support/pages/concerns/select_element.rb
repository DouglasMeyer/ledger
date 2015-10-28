class SelectElement < SitePrism::Section
  def set(text)
    xpath = "option[normalize-space(text())='#{text}']"
    root_element.find(:xpath, xpath).select_option
  end
end
