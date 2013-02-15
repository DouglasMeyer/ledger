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
end
