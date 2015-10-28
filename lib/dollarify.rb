module Dollarify
  def dollarify(cents)
    name = cents.to_s.remove(/_cents$/)

    define_method name do
      send(cents) / 100.0 if cents
    end

    define_method "#{name}=" do |val|
      val = val.delete(",").to_f if val.is_a? String
      send("#{cents}=", (val * 100).round)
    end
  end
end
