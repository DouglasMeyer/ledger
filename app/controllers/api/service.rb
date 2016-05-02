module API
  module Service
    private

    def camelize(obj)
      obj.inject({}) do |acc, (key, val)|
        new_key = key.gsub(/_\w/){ |w| w[1].upcase }
        if val.is_a? Array
          acc[new_key] = val.map{ |v| camelize v }
        elsif val.is_a? Hash
          acc[new_key] = camelize val
        else
          acc[new_key] = val
        end
        acc
      end
    end
  end
end
