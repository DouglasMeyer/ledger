class ApiController < ApplicationController
  class ImpossibleAction < StandardError
  end
  class InvalidQuery < StandardError
  end

  class ApiResponse
    attr_reader :responses, :records

    def initialize
      @responses = []
      @records = {}
    end

    # { records: records, associated: records, errors: errors, data: data }
    def <<(response)
      records = response.delete(:records)
      if records
        response[:records] = records.map do |record|
          class_name = record.class.name
          id         = record.id

          @records[class_name] ||= {}
          serializer = ActiveModel::Serializer.serializer_for(record)
          if serializer
            object = serializer.new(record, root: false)
            @records[class_name][id] = object
          else
            @records[class_name][id] = record
          end
          { type: class_name, id: id }
        end
      end

      (response.delete(:associated) || []).each do |record|
        class_name = record.class.name
        id         = record.id

        @records[class_name] ||= {}
        @records[class_name][id] = record
      end

      @responses << response
    end

    def as_json(options = {})
      { responses: responses, records: records }.as_json(options)
    end

    def any_errors?
      @responses.any? { |r| r.key? :errors }
    end
  end

  def bulk
    api_response = ApiResponse.new

    ActiveRecord::Base.transaction do
      JSON.parse(request.body.string).each do |command|
        constant = get_request_resource(command['resource'])
        if !constant.nil? && constant.respond_to?(command['action'])
          response = constant.send(command['action'], command)
          if command.key?('reference')
            response['reference'] = command['reference']
          end
          api_response << response
        else
          fail ImpossibleAction,
               "#{command['resource']}.#{command['action']} " \
               "isn't an accepted resource/action"
        end
      end
    end

    status = api_response.any_errors? ? :multi_status : :ok
    render json: api_response, status: status
  end

  private

  def get_request_resource(resource_name)
    self.class.const_get(resource_name)
  rescue
    nil
  end

  module Service
    private

    def camelize(obj)
      obj.each_with_object({}) do |(key, val), acc|
        new_key = key.gsub(/_\w/) { |w| w[1].upcase }
        if val.is_a? Array
          acc[new_key] = val.map { |v| camelize v }
        elsif val.is_a? Hash
          acc[new_key] = camelize val
        else
          acc[new_key] = val
        end
      end
    end
  end

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
        deleted_at: Time.zone.now
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
          fail InvalidQuery,
               "#{{ column => val }.inspect} is not a valid query."
        end
      end

      records
    end
  end

  module BankEntry_v1
    extend Service

    def self.read(command)
      if command['needsDistribution'] == true
        records = ::BankEntry
                  .needs_distribution
                  .with_balance
        { records: records }
      else
        records = ::BankEntry
                  .with_balance
                  .limit(command['limit'] || 25)
                  .offset(command['offset'] || 0)
        account_entries = ::AccountEntry.where(
          bank_entry_id: records.pluck(:id)
        )
        { records: records, associated: account_entries }
      end
    end

    def self.create(command)
      record = ::BankEntry.create!(command['data'])
      { records: [ record ], associated: record.accounts }
    end

    def self.update(command)
      record = ::BankEntry.find(command['id'])
      record.update!(command['data'])
      { records: [ record ], associated: record.accounts }
    end
  end

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

  module LedgerSummary_v1
    def self.read(_command)
      latest_bank_import = ::BankImport
                           .order(created_at: :desc)
                           .first
      {
        data: {
          latest_bank_import: latest_bank_import,
          ledger_sum_cents: BankEntry.sum(:amount_cents)
        }
      }
    end
  end
end
