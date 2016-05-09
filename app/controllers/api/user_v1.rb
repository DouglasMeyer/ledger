module API
  module User_v1
    extend Service

    def self.read(command)
      return { errors: ["Only the admin is authorized to be here"] } unless AuthIsAdmin.new(command['user']).success?
      records = ::User
                .limit(command['limit'] || 25)
                .offset(command['offset'] || 0)
      { records: records }
    end
  end
end
