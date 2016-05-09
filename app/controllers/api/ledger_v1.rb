module API
  module Ledger_v1
    extend Service

    def self.read(command)
      return { errors: ["Only the admin is authorized to be here"] } unless AuthIsAdmin.new(command['user']).success?
      { data: ::TenantLedger.all }
    end

    def self.create(command)
      return { errors: ["Only the admin is authorized to be here"] } unless AuthIsAdmin.new(command['user']).success?
      record = ::TenantLedger.create(command['data'])
      { data: command['data'] }
    end

    def self.delete(command)
      return { errors: ["Only the admin is authorized to be here"] } unless AuthIsAdmin.new(command['user']).success?
      ::TenantLedger.delete(command['id'])
      { records: [] }
    end
  end
end
