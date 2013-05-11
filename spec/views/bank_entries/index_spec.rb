require File.expand_path '../../../spec_helper', __FILE__

describe "v2/bank_entries/_bank_entry" do

  it "doesn't show deleted accounts" do
    removed_account = Account.make! deleted_at: 1.minute.ago
    bank_entry = BankEntry.make!

    assign(:account_names, Account.where(deleted_at: nil).order(:name).pluck(:name))
    render locals: { bank_entry: bank_entry }, template: 'v2/bank_entries/_bank_entry'
    expect(rendered).not_to have_selector(%|.account select option[value="#{removed_account.name}"]|)
  end

  it "shows a deleted account if that is the selected account" do
    removed_account = Account.make! deleted_at: 1.minute.ago
    bank_entry = BankEntry.make! ammount_cents: 12_34
    bank_entry.account_entries.create! account: removed_account, ammount_cents: 12_34

    assign(:account_names, Account.where(deleted_at: nil).order(:name).pluck(:name))
    render locals: { bank_entry: bank_entry }, template: 'v2/bank_entries/_bank_entry'
    expect(rendered).to have_selector(%|.account select option[value="#{removed_account.name}"]|)
  end

end
