class ApiController < ApplicationController

  def bulk
    response_json = []
    request_failed = false
    rollback = params[:rollbackAll] != "false"

    ActiveRecord::Base.transaction do
      JSON.parse(params[:body]).each do |command|
        case command['action']
        when 'read'
          node = read(command['type'], command['query'])
          node['reference'] = command['reference'] if command.has_key?('reference')
          response_json << node
        when 'create'
          node = create(command['type'], command['data'])
          node['reference'] = command['reference'] if command.has_key?('reference')
          response_json << node
        else
          #Raise something
        end
      end
      request_failed = response_json.any?{|node| node.has_key? :errors }
      raise ActiveRecord::Rollback if rollback && request_failed
    end

    status = request_failed ? ( rollback ? :bad_request : :multi_status ) : :ok
    render json: response_json, status: status
  end

private

  def read(type, query=nil)
    records = type_to_class(type).all
    records = records.where(query) if query
    { data: records }
  end

  def create(type, data)
    { data: type_to_class(type).create!(data) }
  rescue ActiveRecord::RecordInvalid => e
    { errors: e.record.errors, data: e.record }
  end

  def type_to_class(type)
    case type
    when 'account'
      Account
    when 'bank_entry'
      BankEntry
    when 'account_entry'
      AccountEntry
    else
      #Raise something
    end
  end

end
