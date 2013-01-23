module V2
  module BankEntriesHelper

    def account_balance_without_bank_entry(account, bank_entry)
      ids = bank_entry.account_entries.pluck(:id)
      if ids.any?
        account_entries = account.entries.where("id NOT IN (?)", ids)
      else
        account_entries = account.entries
      end
      account_entries.pluck(:ammount_cents).sum / 100.0
    end

    def account_entry_fields(f, account)
      account_entries = f.object.account_entries.where(account_id: account.id)
      account_entry = if account_entries.any?
                        account_entries.shift
                      else
                        f.object.account_entries.build({account_id: account.id, ammount_cents: 0}, without_protection: true)
                      end
      account_entry.ammount_cents += account_entries.sum(&:ammount_cents)
      account_entry.strategy ||= account.strategy
      account_entry.ammount ||= account_entry.strategy.value(f.object)

      f.fields_for(:account_entries, account_entries){ |ae|
        ae.hidden_field :_destroy, value: true
      } +
      f.fields_for(:account_entries, account_entry){|ae|
        account_balance = account_balance_without_bank_entry(account, f.object)
        content_tag :li, data: { account_balance: account_balance } do
          render partial: 'account', locals: { f: ae, account_balance: account_balance }
        end
      }
    end

  end
end
