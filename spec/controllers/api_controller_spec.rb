require 'rails_helper'

describe ApiController do
  before do
    @blank_account = {
      class_name: 'Account', id: nil, created_at: nil, updated_at: nil, deleted_at: nil,
      name: nil, position: nil, category: nil, strategy_id: nil, balance_cents: 0
    }.stringify_keys
    session[:auth_user] = :yes
  end

  def response_records(records)
    records.map do |r|
      { 'type' => r.class.name, 'id' => r.id }
    end
  end

  def records_by_id(records)
    serializer = ActiveModel::Serializer.serializer_for(records.first)
    records.inject({}) do |acc, r|
      if serializer
        acc[r.id] = serializer.new(r, root: false)
      else
        acc[r.id] = r
      end
      acc
    end
  end

  describe "reading a collection" do
    before do
      Account.make!
      Account.make!
      Account.make!

      post :bulk, [
        { resource: 'Account_v1', action: :read }
      ].to_json
    end

    it "responds with the collection" do
      expect(response.body).to be_json_eql({
        responses: [
          { records: response_records(Account.all) }
        ],
        records: {
          Account: records_by_id(Account.all)
        }
      }.to_json)
    end
  end
  describe "reading a collection with a query" do
    before do
      Account.make!
      @account = Account.make!
      Account.make!

      post :bulk, [
        { resource: 'Account_v1', action: :read, query: { id: [ @account.id ] } }
      ].to_json
    end

    it "responds with the collection matching the query" do
      expect(response.body).to be_json_eql({
        responses: [
          { records: response_records(Account.where(id: @account.id)) }
        ],
        records: {
          Account: records_by_id(Account.where(id: @account.id))
        }
      }.to_json)
    end
  end
  describe "reading a collection with an invalid query" do
    it "raises a InvalidQuery exception" do
      expect(lambda {
        post :bulk, [
          { resource: 'Account_v1', action: :read, query: { blas: 'true' } }
        ].to_json
      }).to raise_error(API::InvalidQuery, '{"blas"=>"true"} is not a valid query.')
    end
  end
  describe "reading a collection with pagination" do
    it "works" do
      @account1 = Account.make!
      @account2 = Account.make!

      post :bulk, [
        { resource: 'Account_v1', action: :read, limit: 1 },
        { resource: 'Account_v1', action: :read, limit: 1, offset: 1 }
      ].to_json

      expect(response.body).to be_json_eql({
        responses: [
          { records: response_records([ @account1 ]) },
          { records: response_records([ @account2 ]) }
        ],
        records: {
          Account: records_by_id([ @account1, @account2 ])
        }
      }.to_json)
    end
  end

  describe "creating a record" do
    before do
      post :bulk, [
        { resource: 'Account_v1', action: :create, reference: 'the new record',
          data: { name: 'New Account', asset: 'true' }
        }
      ].to_json
    end

    it "creates the record" do
      expect(Account.where(name: 'New Account').first.asset).to eq(true)
    end
    it "responds with the new record and reference" do
      expect(response.body).to be_json_eql({
        responses: [
          {
            reference: 'the new record',
            records: response_records([Account.first])
          }
        ],
        records: {
          Account: records_by_id([Account.first])
        }
      }.to_json)
    end
  end

  describe "updating a record" do
    let(:account){ Account.make! asset: false }
    before do
      post :bulk, [
        { resource: 'Account_v1', action: :update, id: account.id, reference: 'updating the record',
          data: { name: 'New Account Name', asset: 'true' }
        }
      ].to_json
    end

    it "updates the record" do
      expect(account.reload.name).to eq('New Account Name')
      expect(account.reload.asset).to eq(true)
    end
    it "responds with the updated record and reference" do
      expect(response.body).to be_json_eql({
        responses: [
          {
            reference: 'updating the record',
            records: response_records([ account ])
          }
        ],
        records: {
          Account: records_by_id([ account.reload ])
        }
      }.to_json)
    end
  end

  describe "attempting to perform an impossible action" do
    it "raises a ImpossibleAction exception" do
      expect(lambda {
        post :bulk, [
          { resource: 'Something', action: :something }
        ].to_json
      }).to raise_error(API::ImpossibleAction, "Something.something isn't an accepted resource/action")
    end
  end

  describe "failing to create a record" do
    before do
      @account1_data = { 'asset' => true }
      @account2_data = { 'name' => 'New Account', 'asset' => true }
      post :bulk, [
        { resource: 'Account_v1', action: :create, reference: 'failed creation', data: @account1_data },
        { resource: 'Account_v1', action: :create, reference: 'actual created', data: @account2_data }
      ].to_json
      @json_response = JSON.parse(response.body)
      @response_references = @json_response['responses'].inject({}) do |acc, n|
        acc[n['reference']] = n
        acc
      end
    end

    it "has a response of :multi_status" do
      expect(response.status).to eq(207)
    end
    it "creates only 1 record" do
      expect(Account.count).to eq(1)
    end
    it "responds with invalid record" do
      expect(@response_references['failed creation']).to eq({
        reference: 'failed creation',
        data: @blank_account.merge(@account1_data),
        errors: { 'name' => ["can't be blank"] }
      }.stringify_keys)
    end
    it "responds with the created record" do
      expect(@response_references['actual created']).to eq({
        reference: 'actual created',
        records: response_records([ Account.first ])
      }.stringify_keys)
    end
  end

  describe "ProjectedEntry_v1.read" do
    it "responds with collection" do
      ProjectedEntry.make!
      ProjectedEntry.make!

      post :bulk, [
        { resource: 'ProjectedEntry_v1', action: :read }
      ].to_json
      expect(response.body).to be_json_eql({
        responses: [{
          records: response_records(ProjectedEntry.all)
        }],
        records: {
          ProjectedEntry: records_by_id(ProjectedEntry.all)
        }
      }.to_json)
    end

    it "paginates the response" do
      ProjectedEntry.make!
      ProjectedEntry.make!
      ProjectedEntry.make!

      post :bulk, [
        { resource: 'ProjectedEntry_v1', action: :read, limit: 2 }
      ].to_json
      expect(response.body).to be_json_eql({
        responses: [{
          records: response_records(ProjectedEntry.limit(2).all)
        }],
        records: {
          ProjectedEntry: records_by_id(ProjectedEntry.limit(2).all)
        }
      }.to_json)

      post :bulk, [
        { resource: 'ProjectedEntry_v1', action: :read, limit: 2, offset: 2 }
      ].to_json
      expect(response.body).to be_json_eql({
        responses: [{
          records: response_records([ ProjectedEntry.last ])
        }],
        records: {
          ProjectedEntry: records_by_id([ ProjectedEntry.last ])
        }
      }.to_json)
    end
  end

  describe "ProjectedEntry_v1.create" do
    it "creates projected entry" do
      account = Account.make!
      data = {
        account_name: account.name,
        amount: '$100.34',
        rrule: 'FREQ=MONTHLY'
      }

      post :bulk, [
        { resource: 'ProjectedEntry_v1', action: 'create', reference: 'create projected entry',
          data: data }
      ].to_json

      projected_entry = ProjectedEntry.last
      expect(response.body).to be_json_eql({
        responses: [{
          reference: 'create projected entry',
          records: [{ type: 'ProjectedEntry', id: projected_entry.id }]
        }],
        records: {
          ProjectedEntry: records_by_id([ projected_entry ])
        }
      }.to_json)
    end
  end

  describe "ProjectedEntry_v1.update" do
    it "updates a projected entry" do
      projected_entry = ProjectedEntry.make!

      account = Account.make!

      data = {
        account_name: account.name,
        amount: '$100.34',
        rrule: 'FREQ=MONTHLY'
      }

      post :bulk, [
        { resource: 'ProjectedEntry_v1', action: 'update', id: projected_entry.id, reference: 'update projected entry',
          data: data }
      ].to_json

      projected_entry.reload
      expect(projected_entry.account_name).to eq(account.name)
      expect(response.body).to be_json_eql({
        responses: [{
          reference: 'update projected entry',
          records: [{ type: 'ProjectedEntry', id: projected_entry.id }]
        }],
        records: {
          ProjectedEntry: records_by_id([ projected_entry ])
        }
      }.to_json)
    end
  end

  describe "ProjectedEntry_v1.delete" do
    it "deletes a projected entry" do
      projected_entry = ProjectedEntry.make!

      post :bulk, [
        { resource: 'ProjectedEntry_v1', action: 'delete', id: projected_entry.id, reference: 'delete projected entry' }
      ].to_json

      expect(Proc.new{ projected_entry.reload }).to raise_error ActiveRecord::RecordNotFound
      expect(response.body).to be_json_eql({
        responses: [{
          reference: 'delete projected entry',
          records: []
        }],
        records: {
        }
      }.to_json)
    end
  end

  describe "Account_v1.delete" do
    it "sets the deleted_at column" do
      account = Account.make!

      data = { id: account.id }
      post :bulk, [
        { resource: 'Account_v1', action: 'delete', id: account.id, refrence: 'delete account', data: data }
      ].to_json

      expect(account.reload.deleted_at).to_not be_nil
    end

    it "updates the record" do
      account = Account.make!

      data = {
        id: account.id,
        position: 12
      }
      post :bulk, [
        { resource: 'Account_v1', action: 'delete', id: account.id, refrence: 'delete account', data: data }
      ].to_json

      expect(account.reload.position).to eq(12)
    end
  end

  describe "LedgerSummary_v1.read" do
    it "responds with collection" do
      BankImport.make!
      latest_bank_import = BankImport.make!
      BankEntry.make!(amount_cents:  1_00)
      BankEntry.make!(amount_cents: -1_00)
      BankEntry.make!(amount_cents: -1_00)
      BankEntry.make!(amount_cents:  1_00)
      BankEntry.make!(amount_cents:  1_00)
      ledger_sum_cents = 1_00

      post :bulk, [
        { resource: 'LedgerSummary_v1', action: :read }
      ].to_json
      expect(response.body).to be_json_eql({
        responses: [{
          data: {
            latest_bank_import: latest_bank_import,
            ledger_sum_cents: ledger_sum_cents
          }
        }],
        records: {}
      }.to_json)
    end
  end
end
