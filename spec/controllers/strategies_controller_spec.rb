require 'rails_helper'

describe V2::StrategiesController do

  describe "GET index" do
    before do
      @account2 = Account.make! position: 3
      Account.make! position: 2, deleted_at: 1.minute.ago
      @account1 = Account.make! position: 1
      get :index
    end

    it "assigns @accounts" do
      expect(assigns(:accounts)).to eq([ @account1, @account2 ])
    end
  end

end
