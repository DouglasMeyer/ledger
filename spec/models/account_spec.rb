require File.expand_path '../../spec_helper', __FILE__

describe Account do
  def add_ae(ammount, month, day, from_bank=true)
    AccountEntry.make! account: @account,
                 ammount_cents: ammount * 100,
                    bank_entry: BankEntry.make!(ammount_cents: ammount * 100,
                                                         date: Date.new(2013, month, day),
                                                  external_id: from_bank ? BankEntry.count : nil)
  end

  it "can't be deleted with a balance" do
    account = AccountEntry.make!(ammount_cents: 20_00).account
    expect{ account.update_attributes!(deleted_at: Time.now) }.to raise_error
  end

  describe "average_spent" do
    it "is calculated from spending" do
      @account = Account.make!
      add_ae -100, 1,  1
      add_ae  -50, 1, 10
      add_ae -200, 1, 20
      add_ae -350, 2,  1
      add_ae  999, 2,  1
      add_ae -999, 2,  1, false
      add_ae  -50, 3,  5
      add_ae  -50, 3, 15
      add_ae -100, 3, 10
      add_ae -150, 3, 31

      expect(@account.average_spent).to be_within(5).of(-350)
    end

    it "is nil for no spending" do
      @account = Account.make!
      add_ae  999, 2,  1
      add_ae -999, 2,  1, false

      expect(@account.average_spent).to be_nil
    end

    it "returns the ammount as dollars per x" do
      @account = Account.make!
      add_ae -100, 1,  1
      add_ae  -50, 1, 10
      add_ae -200, 1, 31

      expect(@account.average_spent(0.5)).to be_within(6).of(-175)
    end
  end

end
