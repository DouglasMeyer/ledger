namespace :db do

  def report_entries(file)
    puts "Row count: #{BankEntry.count + AccountEntry.count}"
    CSV.open(file, 'wb') do |csv|
      csv << ['Name', 'Balance']
      Account.all.each do |account|
        csv << [account.name, account.balance]
      end
    end
    puts "Balances captured in #{file}"
  end

  desc 'Condense account_entries and bank_entries'
  task condense: :environment do
    require 'csv'

    report_entries('before.csv')

    row_count = BankEntry.count + AccountEntry.count
    pct_to_remove = (row_count - 7_000) / row_count.to_f
    if pct_to_remove <= 0
      puts "Nothing to remove"
      exit
    end

    last_bank_entries = BankEntry.last(BankEntry.count * pct_to_remove)
    puts "Condensing #{last_bank_entries.count} bank entries."
    base_bank_entry = BankEntry.new(
      date: last_bank_entries.last.date,
      amount_cents: 0,
      description: 'Initial balance.'
    )
    BankEntry.transaction do
      last_bank_entries.each do |bank_entry|
        base_bank_entry.amount_cents += bank_entry.amount_cents
        bank_entry.account_entries.each do |account_entry|
          base_account_entry = base_bank_entry.account_entries.detect do |ae|
            ae.account_id == account_entry.account_id
          end
          if base_account_entry.nil?
            base_account_entry = base_bank_entry.account_entries.build(
              account_id: account_entry.account_id,
              amount_cents: 0
            )
          end
          base_account_entry.amount_cents += account_entry.amount_cents

          account_entry.destroy!
        end

        bank_entry.reload.destroy!
      end
      base_bank_entry.save!
    end


    report_entries('after.csv')
  end

end
