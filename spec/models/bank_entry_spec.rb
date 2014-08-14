require File.expand_path '../../spec_helper', __FILE__

describe BankEntry do
  describe "#amount" do
    it "is nil when amount_cents is nil" do
      BankEntry.new.amount.should be_nil
    end
  end

  describe "#amount_remaining" do
    it "is 0 when amount_cents is nil" do
      BankEntry.new.amount_remaining.should be(0)
    end
  end

  describe "#from_bank?" do
    it "is true when external_id is present" do
      bank_entry = BankEntry.new
      bank_entry.external_id = 123
      bank_entry.from_bank?.should be(true)
    end
    it "is false when external_id is nil" do
      BankEntry.new.from_bank?.should be(false)
    end

    it "prevents changes to external_id" do
      be = BankEntry.make!(external_id: 1)
      be.external_id = nil
      be.valid?.should be(false)
      be.errors[:external_id].should eq([I18n.t('errors.messages.immutable')])
    end

    it "prevents changes to date" do
      be = BankEntry.make!(external_id: 1)
      be.date = 1.week.ago
      be.valid?.should be(false)
      be.errors[:date].should eq([I18n.t('errors.messages.immutable')])
    end

    it "prevents changes to description" do
      be = BankEntry.make!(external_id: 1)
      be.description = "Something new"
      be.valid?.should be(false)
      be.errors[:description].should eq([I18n.t('errors.messages.immutable')])
    end

    it "prevents changes to amount_cents" do
      be = BankEntry.make!(external_id: 1)
      be.amount_cents = 123_45
      be.valid?.should be(false)
      be.errors[:amount_cents].should eq([I18n.t('errors.messages.immutable')])
    end

    it "allows changes when not from_bank?" do
      be = BankEntry.make!(external_id: nil)
      be.date = 1.week.ago
      be.description = "Something new"
      be.amount_cents = 123_45
      be.valid?.should be(true)
    end
  end

  describe ".join_aggrigate_account_entries" do
    it "includes 'aggrigate_account_entries.amount_cents'" do
      be = BankEntry.make!
      AccountEntry.make! bank_entry: be, amount_cents: 10_12
      AccountEntry.make! bank_entry: be, amount_cents:  8_15

      be = BankEntry.join_aggrigate_account_entries.select('aggrigate_account_entries.amount_cents').find(be.id)
      be.amount_cents.should eq(10_12 + 8_15)
    end

    it "includes records without account_entries" do
      be = BankEntry.make!
      BankEntry.join_aggrigate_account_entries.find(be.id).should_not be_nil
    end
  end

  describe ".needs_distribution" do
    it "has entries that need distribution" do
      BankEntry.make! amount_cents: 0
      BankEntry.make! amount_cents: 10
      be = BankEntry.make!
      AccountEntry.make! bank_entry: be, amount_cents: be.amount_cents

      BankEntry.needs_distribution.count.should eq(1)
    end
  end

  describe ".join_aggrigate_bank_entries" do
    let :bank_entries do
      [
        BankEntry.make!(amount_cents: 1, date: 1.day.ago),
        BankEntry.make!(amount_cents: 9, date: 2.days.ago),
        BankEntry.make!(amount_cents: 10, date: 3.days.ago)
      ]
    end

    it "includes balance_cents" do
      bes = bank_entries
      BankEntry.join_aggrigate_bank_entries.pluck('bank_entries.id, aggrigate_bank_entries.balance_cents').should eq([
        [ bes[0].id, bes[0].amount_cents ],
        [ bes[1].id, bes[0].amount_cents + bes[1].amount_cents ],
        [ bes[2].id, bes[0].amount_cents + bes[1].amount_cents + bes[2].amount_cents ]
      ])
    end

    describe ".with_balance" do
      it "includes the balance" do
        bes = bank_entries
        BankEntry.with_balance.map{|be| [be.id, be.balance_cents]}.should eq([
          [ bes[0].id, bes[0].amount_cents ],
          [ bes[1].id, bes[0].amount_cents + bes[1].amount_cents ],
          [ bes[2].id, bes[0].amount_cents + bes[1].amount_cents + bes[2].amount_cents ]
        ])
      end
    end
  end
end
