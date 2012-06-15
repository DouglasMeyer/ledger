namespace :statement do

  desc 'Fetch and import statement from Harris'
  task :fetch => :environment do
    require Rails.root.join('lib/fetch_statement')
    FetchStatement.run
    #Rake::Task['statement:import'].invoke
  end

  desc 'Import statements from tmp/downloads directory'
  task :import => :environment do
    require Rails.root.join('lib/import_statement')
    dir = Rails.root.join('tmp/downloads')
    statements = dir.entries.map{|e| dir + e }.select(&:file?)
    statements.each do |statement|
      ImportStatement.run(statement)
      statement.delete
    end
  end

end
