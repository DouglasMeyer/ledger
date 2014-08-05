class ApiController < ApplicationController
  class ImpossibleAction < StandardError
  end

  def bulk
    response_json = []
    request_failed = false
    rollback = params[:rollbackAll] != "false"

    ActiveRecord::Base.transaction do
      JSON.parse(params[:body]).each do |command|
        constant = self.class.const_get(command['type']) rescue nil
        if !constant.nil? && constant.respond_to?(command['action'])
          response_json << constant.send(command['action'], command)
          next
        end

        case command['action']
        when 'read'
          command['limit'] ||= 25
          command['offset'] ||= 0
          node = read(command['type'], command['query'], command['limit'], command['offset'])
          node['reference'] = command['reference'] if command.has_key?('reference')
          response_json << node
        when 'create'
          node = create(command['type'], command['data'])
          node['reference'] = command['reference'] if command.has_key?('reference')
          response_json << node
        when 'update'
          node = update(command['type'], command['id'], command['data'])
          node['reference'] = command['reference'] if command.has_key?('reference')
          response_json << node
        else
          raise ImpossibleAction.new command['action'] + " isn't an accepted action"
        end
      end
      request_failed = response_json.any?{|node| node.has_key? :errors }
      raise ActiveRecord::Rollback if rollback && request_failed
    end

    status = request_failed ? ( rollback ? :bad_request : :multi_status ) : :ok
    render json: response_json, status: status
  end

private

  def read(type, query, limit, offset)
    records = type_to_class(type).limit(limit).offset(offset)
    records = records.where(query) if query
    { data: records }
  end

  def create(type, data)
    { data: type_to_class(type).create!(data) }
  rescue ActiveRecord::RecordInvalid => e
    { errors: e.record.errors, data: e.record }
  end

  def update(type, id, data)
    record = type_to_class(type).find(id)
    record.update!(data)
    { data: record }
  end

  def type_to_class(type)
    case type
    when 'account'
      ::Account
    when 'bank_entry'
      ::BankEntry.with_balance
    when 'account_entry'
      ::AccountEntry
    else
      raise ImpossibleAction.new type + " isn't an accepted type"
      #Raise something
    end
  end

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

  module BankEntry
    extend Service

    def self.read(command)
      records = ::BankEntry
        .with_balance
        .limit(command['limit'] || 25)
        .offset(command['offset'] || 0)
      records = records.where(command['query']) if command['query']
      account_entries = ::AccountEntry.where(bank_entry_id: records.pluck(:id))
      node = { data: records, associated: account_entries }
      node['reference'] = command['reference'] if command.has_key?('reference')
      node
    end
  end
end
