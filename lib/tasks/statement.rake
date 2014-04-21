namespace :statement do

  def json_file
    @json_file ||= Rails.root + 'tmp' + 'new_bank_entries.json'
  end

  desc 'Fetch statement from Harris'
  task :fetch => :environment do
    require Rails.root + 'lib' + 'fetch_statement'
    FetchStatement.run
    Rake::Task['statement:parse'].invoke
  end

  task :parse => :environment do
    require Rails.root + 'lib' + 'parse_statement'
    bank_entries = JSON.parse(File.read(json_file)) rescue []

    (Rails.root + 'tmp' + 'downloads').entries.each do |statement|
      statement = Rails.root + 'tmp' + 'downloads' + statement
      next unless statement.file?
      bank_entries += ParseStatement.run(statement).compact
      statement.delete
    end
    File.open(json_file, 'w'){ |f| f.write(bank_entries.to_json) }
  end

  desc 'Import statements from tmp/downloads directory'
  task :import => :environment do
    JSON.parse(File.read(json_file)).each do |attributes|
      unless BankEntry.where(external_id: attributes['external_id']).any?
        BankEntry.create!(attributes)
      end
    end
  end

  desc 'Send statement data to production'
  task :send => :environment do
    require 'httparty'
    require "net/netrc"
    require 'fileutils'

    FileUtils.cp json_file, Rails.root + 'tmp' + "sent_bank_entries #{Time.now}.json"

    netrc = Net::Netrc.locate('harrisbank.com')
    request = []
    JSON.parse(File.read(json_file)).each do |bank_entry|
      request << { action: :create, type: :bank_entry, data: bank_entry }
    end
    response = HTTParty.post "http://ledger.herokuapp.com/api.json", {
      basic_auth: { username: netrc.login, password: netrc.password },
      body: {
        body: request.to_json,
        rollbackAll: false
      }
    }
    json_response = JSON.parse(response.body)
    pp json_response
    return unless json_response.is_a?(Array)
    bank_entries = json_response.map do |bank_entry|
      if errors = bank_entry['errors']
        unless errors['external_id'].include?('has already been taken')
          pp errors
          return bank_entry['data']
        end
      end
    end.compact
    File.open(json_file, 'w'){ |f| f.write(bank_entries.to_json) }
  end

end

desc 'Fetch, Send, and Import statement'
task :statement => [ 'statement:fetch', 'statement:import', 'statement:send' ]
