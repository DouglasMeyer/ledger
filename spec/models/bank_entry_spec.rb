require File.expand_path '../../spec_helper', __FILE__

describe BankEntry do
  describe "#ammount" do
    it "is nil when ammount_cents is nil" do
      BankEntry.new.ammount.should be_nil
    end
  end

  describe "#ammount_remaining" do
    it "is 0 when ammount_cents is nil" do
      BankEntry.new.ammount_remaining.should be(0)
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

    it "prevents changes to ammount_cents" do
      be = BankEntry.make!(external_id: 1)
      be.ammount_cents = 123_45
      be.valid?.should be(false)
      be.errors[:ammount_cents].should eq([I18n.t('errors.messages.immutable')])
    end

    it "allows changes when not from_bank?" do
      be = BankEntry.make!(external_id: nil)
      be.date = 1.week.ago
      be.description = "Something new"
      be.ammount_cents = 123_45
      be.valid?.should be(true)
    end
  end

  describe ".join_aggrigate_account_entries" do
    it "includes 'aggrigate_account_entries.ammount_cents'" do
      be = BankEntry.make!
      AccountEntry.make! bank_entry: be, ammount_cents: 10_12
      AccountEntry.make! bank_entry: be, ammount_cents:  8_15

      be = BankEntry.join_aggrigate_account_entries.select('aggrigate_account_entries.ammount_cents').find(be.id)
      be.ammount_cents.should eq(10_12 + 8_15)
    end

    it "includes records without account_entries" do
      be = BankEntry.make!
      BankEntry.join_aggrigate_account_entries.find(be.id).should_not be_nil
    end
  end

  describe ".needs_distribution" do
    it "has entries that need distribution" do
      BankEntry.make! ammount_cents: 0
      BankEntry.make! ammount_cents: 10
      be = BankEntry.make!
      AccountEntry.make! bank_entry: be, ammount_cents: be.ammount_cents

      BankEntry.needs_distribution.count.should eq(1)
    end
  end

  describe "after_create :ensures_ledger_sum" do
    it "creates a new bank_entry to account for the difference" do
      BankEntry.make!(ammount_cents: 10_00, bank_balance_cents: 100_00)

      BankEntry.count.should eq(2)
      BankEntry.first.ammount_cents.should eq(90_00)
    end
  end
end
