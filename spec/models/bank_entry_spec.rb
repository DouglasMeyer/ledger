require File.expand_path '../../spec_helper', __FILE__

describe BankEntry do
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
