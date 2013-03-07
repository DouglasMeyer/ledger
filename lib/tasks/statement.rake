namespace :statement do

  desc 'Fetch, Send, and Import statement'
  task :default => [ :fetch, :send, :import ]

  desc 'Fetch statement from Harris'
  task :fetch => :environment do
    require Rails.root + 'lib' + 'fetch_statement'
    FetchStatement.run
    Rake::Task['statement:parse'].invoke
  end

  task :parse => :environment do
    require Rails.root + 'lib' + 'parse_statement'
    json_file = Rails.root + 'tmp' + 'new_bank_entries.json'
    bank_entries = JSON.parse(File.read(json_file)) rescue []

    (Rails.root + 'tmp' + 'downloads').entries.each do |statement|
      statement = Rails.root + 'tmp' + 'downloads' + statement
      next unless statement.file?
      bank_entries += ParseStatement.run(statement).compact
      #statement.delete
    end
    File.open(json_file, 'w'){ |f| f.write(bank_entries.to_json) }
  end

  desc 'Send statement data to production'
  task :send => :environment do
    require 'httparty'
    require "net/netrc"

    netrc = Net::Netrc.locate('harrisbank.com')
    request = []
    json_file = Rails.root + 'tmp' + 'new_bank_entries.json'
    JSON.parse(File.read(json_file)).each do |bank_entry|
      request << { action: :create, type: :bank_entry, data: bank_entry }
    end
    response = HTTParty.post "http://localhost:3001/api.json", {
#      basic_auth: { username: netrc.login, password: netrc.password },
      body: { body: request.to_json }
    }
    bank_entries = JSON.parse(response.body).map do |bank_entry|
      if errors = bank_entry['errors']
        unless errors['external_id'].include?('has already been taken')
          pp errors
          return bank_entry['data']
        end
      end
    end.compact
    File.open(json_file, 'w'){ |f| f.write(bank_entries.to_json) }
  end

  desc 'Import statements from tmp/downloads directory'
  task :import => :environment do
    require Rails.root + 'lib' + 'import_statement'
    dir = Rails.root.join('tmp/downloads')
    statements = dir.entries.map{|e| dir + e }.select(&:file?)
    statements.each do |statement|
      ImportStatement.run(statement)
      statement.delete
    end
  end

end
