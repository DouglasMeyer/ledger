require File.expand_path '../../spec_helper', __FILE__

describe ApiController do
  before do
    @blank_account = {
      'class_name' => 'Account', 'id' => nil, 'created_at' => nil, 'updated_at' => nil, 'deleted_at' => nil,
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
  describe "reading a collection with pagination" do
    it "works" do
      @account1 = Account.make!
      @account2 = Account.make!

      post :bulk, body: [
        { action: :read, type: :account, limit: 1 },
        { action: :read, type: :account, limit: 1, offset: 1 }
      ].to_json

      response.body.should eq([
        { 'data' => [@account1] },
        { 'data' => [@account2] }
      ].to_json)
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

  describe "updating a record" do
    let(:account){ Account.make! asset: false }
    before do
      post :bulk, body: [
        { action: :update, type: :account, id: account.id, reference: 'updating the record',
          data: { name: 'New Account Name', asset: 'true' }
        }
      ].to_json
    end

    it "updates the record" do
      account.reload.name.should eq('New Account Name')
      account.reload.asset.should eq(true)
    end
    it "responds with the updated record and reference" do
      JSON.parse(response.body).should eq([{
        'reference' => 'updating the record', 'data' => JSON.parse(account.reload.to_json)
      }])
    end
  end

  describe "attempting to perform an impossible action" do
    it "raises a ImpossibleAction exception" do
      lambda {
        post :bulk, body: [
          { action: :something }
        ].to_json
      }.should raise_error(ApiController::ImpossibleAction, "something isn't an accepted action")
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

  describe "BankEntry_v1.read" do
    it "responds with collection" do
      BankEntry.make!
      AccountEntry.make!
      AccountEntry.make!

      post :bulk, body: [
        { type: 'BankEntry_v1', action: :read }
      ].to_json
      response.body.should eq([{
        data: BankEntry.with_balance.all,
        associated: AccountEntry.all
      }].to_json)
    end

    it "paginates the response" do
      AccountEntry.make!
      BankEntry.make!
      AccountEntry.make!

      post :bulk, body: [
        { type: 'BankEntry_v1', action: :read, limit: 2 }
      ].to_json
      response.body.should eq([{
        'data' => BankEntry.with_balance.limit(2).all,
        'associated' => [ AccountEntry.last ]
      }].to_json)

      post :bulk, body: [
        { type: 'BankEntry_v1', action: :read, limit: 2, offset: 2 }
      ].to_json
      response.body.should eq([{
        data: [ BankEntry.with_balance.last ],
        associated: [ AccountEntry.first ]
      }].to_json)
    end
  end

  describe "BankEntry_v1.update" do
    it "updated bank_entry and associated account_entries" do
      bank_entry = AccountEntry.make!.bank_entry
      data = bank_entry.as_json
      data.delete('class_name')
      data.delete('account_entries')
      data['account_entries_attributes'] = bank_entry.account_entries.map(&:as_json)
      data['account_entries_attributes'][0].delete('class_name')

      data['notes'] = 'New Note'

      post :bulk, body: [
        { type: 'BankEntry_v1', action: 'update', reference: 'update bank entry',
          id: bank_entry.id, data: data }
      ].to_json

      bank_entry.reload
      bank_entry.notes.should eq('New Note')
      response.body.should eq([{
        data: bank_entry,
        reference: 'update bank entry'
      }].to_json)
    end

    it "removes account_entries with _destroy attribute" do
      bank_entry = AccountEntry.make!.bank_entry
      data = bank_entry.as_json
      data.delete('class_name')
      data.delete('account_entries')

      data['account_entries_attributes'] = [ { _destroy: true, id: bank_entry.account_entries.first.id } ]

      post :bulk, body: [
        { type: 'BankEntry_v1', action: 'update', id: bank_entry.id, data: data }
      ].to_json

      bank_entry.reload
      bank_entry.account_entries.should eq([])
    end
  end
end
