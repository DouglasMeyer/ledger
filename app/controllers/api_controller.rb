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

    def as_json(options={})
      { responses: responses, records: records }.as_json(options)
    end

    def any_errors?
      @responses.any?{|r| r.has_key? :errors }
    end
  end

  def bulk
    api_response = ApiResponse.new

    ActiveRecord::Base.transaction do
      JSON.parse(request.body.string).each do |command|
        constant = self.class.const_get(command['resource']) rescue nil
        if !constant.nil? && constant.respond_to?(command['action'])
          response = constant.send(command['action'], command)
          response['reference'] = command['reference'] if command.has_key?('reference')
          api_response << response
        else
          raise ImpossibleAction.new "#{command['resource']}.#{command['action']} isn't an accepted resource/action"
        end
      end
    end

    status = api_response.any_errors? ? :multi_status : :ok
    render json: api_response, status: status
  end

private

  module Service
  private

    def camelize obj
      obj.inject({}) do |acc, (key, val)|
        newKey = key.gsub(/_\w/){|w| w[1].upcase }
        if val.is_a? Array
          acc[newKey] = val.map{|v| camelize v }
        elsif val.is_a? Hash
          acc[newKey] = camelize val
        else
          acc[newKey] = val
        end
        acc
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
      record.update!(command['data'].merge({
        deleted_at: Time.now
      }))
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
        account_entries = ::AccountEntry.where(bank_entry_id: records.pluck(:id))
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
  end

  module LedgerSummary_v1
    def self.read(command)
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
