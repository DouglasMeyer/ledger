module V3
  module BankEntriesHelper

    def account_balance_without_bank_entry(account, bank_entry)
      ids = bank_entry.account_entries.pluck(:id)
      if ids.any?
        account_entries = account.entries.where("id NOT IN (?)", ids)
      else
        account_entries = account.entries
      end
      account_entries.pluck(:amount_cents).sum / 100.0
    end

    def account_entry_fields(f, account)
      account_entries = f.object.account_entries.where(account_id: account.id)

      account_entry = f.object.account_entries.build(account_id: account.id, amount_cents: 0)
      account_entry.amount_cents = account_entries.sum(:amount_cents)
      account_entry.strategy = account.strategy
      account_entry.amount = account_entries.first.strategy.value(f.object) if account_entries.first.try(:strategy)

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
