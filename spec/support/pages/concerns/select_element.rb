class SelectElement < SitePrism::Section
  def set(text)
    root_element.find(:xpath, "option[normalize-space(text())='#{text}']").select_option
  end
end
