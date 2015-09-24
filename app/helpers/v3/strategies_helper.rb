module V3
  module StrategiesHelper
    def strategy_title(strategy)
      case strategy.strategy_type
      when 'fixed'
        "Fixed $#{strategy.variable}"
      when 'percent_of_income'
        "#{strategy.variable}% of Income"
      when 'amount_per_month'
        "$#{strategy.variable} per Month"
      end
    end

    def strategy_dot(strategy, bank_entry, options = {})
      class_name = "strategy-dot"
      text = ''
      using = true
      if strategy && !strategy.new_record?
        using = (options[:amount].to_f == strategy.value(bank_entry))
        class_name += " #{'not-' unless using}using"
      end
      if options[:text]
        if strategy.new_record?
          text = "No Strategy"
        else
          text = "#{using ? 'Using' : 'Not using'} Strategy"
        end
      end
      # &middot; &bull;
      content_tag(:span, "&middot;".html_safe, class: class_name) + text
    end
  end
end
