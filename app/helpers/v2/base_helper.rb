module V2
  module BaseHelper

    def currency(val, class_name, tag='div')
      classes = [ 'currency', class_name ]
      classes << 'negative' if val && val < 0
      content_tag(tag, number_to_currency(val), class: classes)
    end

  end
end
