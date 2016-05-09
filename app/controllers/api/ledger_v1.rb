module API
  module Ledger_v1
    extend Service

    def self.read(command)
      return { errors: ["Only the admin is authorized to be here"] } unless AuthIsAdmin.new(command['user']).success?
      { data: ::TenantLedger.all }
    end
  end
end
