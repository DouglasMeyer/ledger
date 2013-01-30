require File.expand_path '../../spec_helper', __FILE__

describe Account do
  it "can't be deleted with a balance" do
    account = AccountEntry.make!(ammount_cents: 20_00).account
    expect{ account.update_attributes!(deleted_at: Time.now) }.to raise_error
  end
end
