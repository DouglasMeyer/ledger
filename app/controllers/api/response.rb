module API
  class Response
    attr_reader :responses, :records

    def initialize
      @responses = []
      @records = {}
    end

    def <<(response) # { records: records, associated: records, errors: errors, data: data }
      if records = response.delete(:records)
        response[:records] = records.map do |record|
          class_name = record.class.name
          id         = record.id

          @records[class_name] ||= {}
          if serializer = ActiveModel::Serializer.serializer_for(record)
            object = serializer.new(record, root: false)
            @records[class_name][id] = object
          else
            @records[class_name][id] = record
          end
          { type: class_name, id: id }
        end
      end

      if records = response.delete(:associated)
        records.each do |record|
          class_name = record.class.name
          id         = record.id

          @records[class_name] ||= {}
          @records[class_name][id] = record
        end
      end

      @responses << response
    end

    def as_json(options = {})
      { responses: responses, records: records }.as_json(options)
    end

    def any_errors?
      @responses.any?{ |r| r.has_key? :errors }
    end
  end
end
