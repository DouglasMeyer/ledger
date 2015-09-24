class Date
  def months
    year * 12 + month + day.to_f / Time.days_in_month(month)
  end
end
