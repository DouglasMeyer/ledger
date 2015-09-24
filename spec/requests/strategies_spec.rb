require 'rails_helper'

describe "show" do

  it "shows new strategies" do
    bank_entry = BankEntry.make!
    account = Account.make!

    get "/v2/strategies/0",
        bank_entry_id: bank_entry.id,
        account_id: account.id,
        entry_amount: '0.00'

    assert_select 'h3', account.name
    assert_select 'h3 + div', /No Strategy/ do
      assert_select '.strategy-dot', '&middot;'
    end
    assert_select 'a.use-strategy', count: 0
    assert_select 'a', 'Set Strategy'
  end

  it "shows a matching strategies (with a note)" do
    bank_entry = BankEntry.make!
    strategy = Strategy.make! strategy_type: :fixed, variable: 12.3
    account = Account.make!

    get "/v2/strategies/#{strategy.id}",
        bank_entry_id: bank_entry.id,
        account_id: account.id,
        entry_amount: '12.30'

    assert_select 'h3', account.name
    assert_select 'h3 + div', /Using Strategy/ do
      assert_select '.strategy-dot.using', '&middot;'
    end
    #FIXME: format 12.3 to 12.30
    assert_select 'h3 + div + div', /Fixed \$12\.3/
    assert_select '.notes', strategy.notes
    assert_select 'a.use-strategy', count: 0
    assert_select 'a', 'Set Strategy'
  end

  it "shows a mis-match strategy (without a note)" do
    bank_entry = BankEntry.make!
    strategy = Strategy.make! strategy_type: :fixed, variable: 12.3, notes: nil
    account = Account.make!
    get "/v2/strategies/#{strategy.id}",
        bank_entry_id: bank_entry.id,
        account_id: account.id,
        entry_amount: '8.00'

    assert_select 'h3', account.name
    assert_select 'h3 + div', /Not using Strategy/ do
      assert_select '.strategy-dot.not-using', '&middot;'
    end
    #FIXME: format 12.3 to 12.30
    assert_select 'h3 + div + div', /Fixed \$12.3/
    assert_select '.notes', count: 0
    assert_select 'a.use-strategy', /Use Strategy/ do
      assert_select '.amount', '$12.30'
    end
    assert_select 'a', 'Set Strategy'
  end

end
