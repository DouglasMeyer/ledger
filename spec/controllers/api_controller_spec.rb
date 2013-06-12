require File.expand_path '../../spec_helper', __FILE__

describe ApiController do
  before do
    @blank_account = {
      'id' => nil, 'created_at' => nil, 'updated_at' => nil, 'deleted_at' => nil,
      'name' => nil, 'position' => nil, 'category' => nil, 'strategy_id' => nil, 'balance_cents' => 0
    }
  end

  describe "reading a collection" do
    before do
      Account.make!
      Account.make!
      Account.make!

      post :bulk, body: [
        { action: :read, type: :account }
      ].to_json
    end

    it "responds with the collection" do
      response.body.should eq([{ 'data' => Account.all }].to_json)
    end
  end
  describe "reading a collection with a query" do
    before do
      Account.make!
      @account = Account.make!
      Account.make!

      post :bulk, body: [
        { action: :read, type: :account, query: { id: [ @account.id ] } }
      ].to_json
    end

    it "responds with the collection matching the query" do
      response.body.should eq([{ 'data' => Account.where(id: @account.id) }].to_json)
    end
  end

  describe "creating a record" do
    before do
      post :bulk, body: [
        { action: :create, type: :account, reference: 'the new record',
          data: { name: 'New Account', asset: 'true' }
        }
      ].to_json
    end

    it "creates the record" do
      Account.where(name: 'New Account').first.asset.should eq(true)
    end
    it "responds with the new record and reference" do
      JSON.parse(response.body).should eq([{
        'reference' => 'the new record', 'data' => JSON.parse(Account.first.to_json)
      }])
    end
  end

  describe "failing to create a record" do
    before do
      @account1_data = { 'asset' => true }
      @account2_data = { 'name' => 'New Account', 'asset' => true }
      post :bulk, body: [
        { action: :create, type: :account, reference: 'invalid', data: @account1_data },
        { action: :create, type: :account, reference: 'valid', data: @account2_data }
      ].to_json
      @json_response = JSON.parse(response.body)
      @response_references = @json_response.inject({}){|acc,n| acc[n['reference']] = n ; acc }
    end

    it "has a response of :bad_request" do
      response.status.should eq(400)
    end
    it "does not create any records" do
      Account.count.should eq(0)
    end
    it "responds with the error" do
      @json_response.length.should eq(2)
      @response_references['invalid'].should eq({
        'reference' => 'invalid',
        'errors' => { 'name' => ["can't be blank"] },
        'data' => @blank_account.merge(@account1_data)
      })
      @response_references['valid'].should eq({
        'reference' => 'valid',
        'data' => @blank_account.merge(@account2_data).merge('created_at' => @response_references['valid']['data']['created_at'],
                                                             'updated_at' => @response_references['valid']['data']['updated_at'])
      })
    end
  end
  describe "failing to create a record with rollbackAll as false" do
    before do
      @account1_data = { 'asset' => true }
      @account2_data = { 'name' => 'New Account', 'asset' => true }
      post :bulk, rollbackAll: "false", body: [
        { reference: 'failed creation', action: :create, type: :account, data: @account1_data },
        { reference: 'actual created',  action: :create, type: :account, data: @account2_data }
      ].to_json
      @json_response = JSON.parse(response.body)
      @response_references = @json_response.inject({}){|acc,n| acc[n['reference']] = n ; acc }
    end

    it "has a response of :multi_status" do
      response.status.should eq(207)
    end
    it "creates only 1 record" do
      Account.count.should eq(1)
    end
    it "responds with invalid record" do
      @response_references['failed creation'].should eq({
        'reference' => 'failed creation',
        'data' => @blank_account.merge(@account1_data),
        'errors' => { 'name' => ["can't be blank"] }
      })
    end
    it "responds with the created record" do
      @response_references['actual created'].should eq({
        'reference' => 'actual created',
        'data' => JSON.parse(Account.first.to_json())
      })
    end
  end
end
