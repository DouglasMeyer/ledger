require File.expand_path '../../spec_helper', __FILE__

describe V2::AccountsController do

  describe "PUT update" do
    it "updates all accounts" do
      account1 = Account.make!
      account2 = Account.make!

      account1_attributes = {
        'id' => account1.id, 'position' => 1, 'name' => 'Tithe',    'category' => 'Charity'
      }
      account2_attributes = {
        'id' => account2.id, 'position' => 2, 'name' => 'Missions', 'category' => 'Charity'
      }

      put :update,
        accounts: {
          accounts_attributes: {
            0 => account1_attributes,
            1 => account2_attributes
          }
        }

      account1.reload.attributes.should include(account1_attributes)
      account2.reload.attributes.should include(account2_attributes)
    end
  end

end
