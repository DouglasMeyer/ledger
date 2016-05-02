module API
  module Account_v1
    def self.read(command)
      records = ::Account.all
      records = records.limit(command['limit']) if command['limit']
      records = records.offset(command['offset']) if command['offset']
      records = query(records, command['query']) if command['query']
      { records: records }
    end

    def self.create(command)
      { records: [ ::Account.create!(command['data']) ] }
    rescue ActiveRecord::RecordInvalid => e
      { errors: e.record.errors, data: e.record }
    end

    def self.update(command)
      record = ::Account.find(command['id'])
      record.update!(command['data'])
      { records: [ record ] }
    end

    def self.delete(command)
      record = ::Account.find(command['id'])
      record_attrs = command['data'].merge(
        deleted_at: Time.now
      )
      record.update! record_attrs
      { records: [ record ] }
    end

    private

    def self.query(records, query)
      query.each do |column, val|
        if column == 'id' && val.is_a?(Array)
          records = records.where(id: val)
        else
          raise InvalidQuery.new "#{{ column => val }.inspect} is not a valid query."
        end
      end

      records
    end
  end
end
