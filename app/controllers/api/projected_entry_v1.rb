module API
  module ProjectedEntry_v1
    extend Service

    def self.read(command)
      records = ::ProjectedEntry
                .limit(command['limit'] || 25)
                .offset(command['offset'] || 0)
      { records: records }
    end

    def self.create(command)
      record = ::ProjectedEntry.create!(command['data'])
      { records: [ record ] }
    end

    def self.update(command)
      record = ::ProjectedEntry.find(command['id'])
      record.update!(command['data'])
      { records: [ record ] }
    end

    def self.delete(command)
      record = ::ProjectedEntry.find(command['id'])
      record.destroy!
      { records: [] }
    end
  end
end
