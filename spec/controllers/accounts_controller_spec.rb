require File.expand_path '../../spec_helper', __FILE__

describe V2::AccountsController do

  describe "GET index" do
    it "loads accounts" do
      account2 = Account.make! position: 3
      Account.make! position: 2, deleted_at: 1.minute.ago
      account1 = Account.make! position: 1

      get :index
      expect(assigns(:accounts)).to eq([ account1, account2 ])
    end
  end

  describe "PUT update" do
    it "updates all accounts" do
      account1 = Account.make!
      account2 = Account.make!

      account1_attributes = {
        'id' => account1.id, 'asset' => true, 'position' => 1, 'name' => 'Tithe',    'category' => 'Charity'
      }
      account2_attributes = {
        'id' => account2.id, 'asset' => false, 'position' => 2, 'name' => 'Missions', 'category' => 'Charity'
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

    it "can delete accounts" do
      account_to_delete = Account.make!
      account_to_keep = Account.make!

      put :update,
        accounts: {
          accounts_attributes: {
            0 => { id: account_to_delete.id, _destroy: '1' },
            1234 => { _destroy: '1', name: 'crazy' }
          }
        }

      account_to_keep.reload
      expect(account_to_delete.reload.deleted_at).to_not be(nil)
      expect(Account.where(name: 'crazy').first).to be(nil)
    end

    it "can create accounts" do
      account_attributes = { 'name' => 'Crazy', 'asset' => true }
      put :update,
        accounts: {
          accounts_attributes: {
            1234 => account_attributes
          }
        }

      Account.where(name: 'Crazy').first.attributes.should include(account_attributes)
    end
  end

end
