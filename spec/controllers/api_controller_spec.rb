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
    records.each_with_object({}) do |r, acc|
      acc[r.id] = serializer ? serializer.new(r, root: false) : r
    end
  end

  describe 'reading a collection' do
    before do
      Account.make!
      Account.make!
      Account.make!

      post :bulk, [
        { resource: 'Account_v1', action: :read }
      ].to_json
    end

    it 'responds with the collection' do
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
  describe 'reading a collection with a query' do
    before do
      Account.make!
      @account = Account.make!
      Account.make!

      post :bulk, [
        { resource: 'Account_v1', action: :read, query: { id: [ @account.id ] } }
      ].to_json
    end

    it 'responds with the collection matching the query' do
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
  describe 'reading a collection with an invalid query' do
    it 'raises a InvalidQuery exception' do
      expect(lambda {
        post :bulk, [
          { resource: 'Account_v1', action: :read, query: { blas: 'true' } }
        ].to_json
      }).to raise_error(ApiController::InvalidQuery, '{"blas"=>"true"} is not a valid query.')
    end
  end
  describe 'reading a collection with pagination' do
    it 'works' do
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

  describe 'creating a record' do
    before do
      post :bulk, [
        { resource: 'Account_v1', action: :create, reference: 'the new record',
          data: { name: 'New Account', asset: 'true' }
        }
      ].to_json
    end

    it 'creates the record' do
      expect(Account.where(name: 'New Account').first.asset).to eq(true)
    end
    it 'responds with the new record and reference' do
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

  describe 'updating a record' do
    let(:account){ Account.make! asset: false }
    before do
      post :bulk, [
        { resource: 'Account_v1', action: :update, id: account.id, reference: 'updating the record',
          data: { name: 'New Account Name', asset: 'true' }
        }
      ].to_json
    end

    it 'updates the record' do
      expect(account.reload.name).to eq('New Account Name')
      expect(account.reload.asset).to eq(true)
    end
    it 'responds with the updated record and reference' do
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

  describe 'attempting to perform an impossible action' do
    it 'raises a ImpossibleAction exception' do
      expect(lambda {
        post :bulk, [
          { resource: 'Something', action: :something }
        ].to_json
      }).to raise_error(ApiController::ImpossibleAction, "Something.something isn't an accepted resource/action")
    end
  end

  describe 'failing to create a record' do
    before do
      @account1_data = { 'asset' => true }
      @account2_data = { 'name' => 'New Account', 'asset' => true }
      post :bulk, [
        { resource: 'Account_v1', action: :create, reference: 'failed creation', data: @account1_data },
        { resource: 'Account_v1', action: :create, reference: 'actual created', data: @account2_data }
      ].to_json
      @json_response = JSON.parse(response.body)
      @response_references = @json_response['responses'].each_with_object({}) do |n, acc|
        acc[n['reference']] = n
      end
    end

    it 'has a response of :multi_status' do
      expect(response.status).to eq(207)
    end
    it 'creates only 1 record' do
      expect(Account.count).to eq(1)
    end
    it 'responds with invalid record' do
      expect(@response_references['failed creation']).to eq({
        reference: 'failed creation',
        data: @blank_account.merge(@account1_data),
        errors: { 'name' => ["can't be blank"] }
      }.stringify_keys)
    end
    it 'responds with the created record' do
      expect(@response_references['actual created']).to eq({
        reference: 'actual created',
        records: response_records([ Account.first ])
      }.stringify_keys)
    end
  end

  describe 'BankEntry_v1.read' do
    it 'responds with collection' do
      BankEntry.make!
      AccountEntry.make!
      AccountEntry.make!

      post :bulk, [
        { resource: 'BankEntry_v1', action: :read }
      ].to_json
      expect(response.body).to be_json_eql({
        responses: [{
          records: response_records(BankEntry.all)
        }],
        records: {
          BankEntry: records_by_id(BankEntry.with_balance.all),
          AccountEntry: records_by_id(AccountEntry.all)
        }
      }.to_json)
    end

    it 'paginates the response' do
      AccountEntry.make!
      BankEntry.make!
      AccountEntry.make!

      post :bulk, [
        { resource: 'BankEntry_v1', action: :read, limit: 2 }
      ].to_json
      expect(response.body).to be_json_eql({
        responses: [{
          records: response_records(BankEntry.limit(2).all)
        }],
        records: {
          BankEntry: records_by_id(BankEntry.with_balance.limit(2).all),
          AccountEntry: records_by_id([ AccountEntry.last ])
        }
      }.to_json)

      post :bulk, [
        { resource: 'BankEntry_v1', action: :read, limit: 2, offset: 2 }
      ].to_json
      expect(response.body).to be_json_eql({
        responses: [{
          records: response_records([ BankEntry.last ])
        }],
        records: {
          BankEntry: records_by_id([ BankEntry.with_balance.last ]),
          AccountEntry: records_by_id([ AccountEntry.first ])
        }
      }.to_json)
    end

    it 'responds with entries needing distribution' do
      needs_distribution = []
      needs_distribution << BankEntry.make!
      BankEntry.make! amount_cents: 0
      needs_distribution << BankEntry.make!

      post :bulk, [
        { resource: 'BankEntry_v1', action: :read, needsDistribution: true }
      ].to_json
      expect(JSON.parse(response.body)['records']['BankEntry']).to eq(
        JSON.parse(records_by_id(BankEntry.with_balance.find(needs_distribution.map(&:id))).to_json)
      )
      expect(response.body).to be_json_eql({
        responses: [{
          records: response_records(needs_distribution.reverse)
        }],
        records: {
          BankEntry: records_by_id(BankEntry.with_balance.find(needs_distribution.map(&:id)))
        }
      }.to_json)
    end
  end

  describe 'BankEntry_v1.update' do
    it 'updated bank_entry and associated account_entries' do
      bank_entry = AccountEntry.make!.bank_entry
      data = bank_entry.as_json
      data.delete('class_name')
      data.delete('account_entries')
      data['account_entries_attributes'] = bank_entry.account_entries.map(&:as_json)
      data['account_entries_attributes'][0].delete('class_name')

      data['notes'] = 'New Note'

      post :bulk, [
        { resource: 'BankEntry_v1', action: 'update', reference: 'update bank entry',
          id: bank_entry.id, data: data }
      ].to_json

      bank_entry.reload
      expect(bank_entry.notes).to eq('New Note')
      expect(response.body).to be_json_eql({
        responses: [{
          reference: 'update bank entry',
          records: [{ type: 'BankEntry', id: bank_entry.id }]
        }],
        records: {
          BankEntry: records_by_id([ bank_entry ]),
          Account: records_by_id(Account.all)
        }
      }.to_json)
    end

    it 'removes account_entries with _destroy attribute' do
      bank_entry = AccountEntry.make!.bank_entry
      data = bank_entry.as_json
      data.delete('class_name')
      data.delete('account_entries')

      data['account_entries_attributes'] = [ { _destroy: true, id: bank_entry.account_entries.first.id } ]

      post :bulk, [
        { resource: 'BankEntry_v1', action: 'update', id: bank_entry.id, data: data }
      ].to_json

      bank_entry.reload
      expect(bank_entry.account_entries).to eq([])
    end
  end

  describe 'BankEntry_v1.create' do
    it 'creates bank_entry and associated account_entries' do
      Account.make! name: 'Benevolence'
      Account.make! name: 'Fun Money'
      data = {
        date: '2014-08-23',
        amount_cents: 0,
        account_entries_attributes: [
          { account_name: 'Benevolence', amount_cents: -100_00 },
          { account_name: 'Fun Money',   amount_cents:  100_00 }
        ]
      }

      post :bulk, [
        { resource: 'BankEntry_v1', action: 'create', reference: 'create bank entry',
          data: data }
      ].to_json

      bank_entry = BankEntry.last
      expect(response.body).to be_json_eql({
        responses: [{
          reference: 'create bank entry',
          records: [{ type: 'BankEntry', id: bank_entry.id }]
        }],
        records: {
          BankEntry: records_by_id([ bank_entry ]),
          Account: records_by_id(Account.all)
        }
      }.to_json)
    end
  end

  describe 'ProjectedEntry_v1.read' do
    it 'responds with collection' do
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

    it 'paginates the response' do
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

  describe 'ProjectedEntry_v1.create' do
    it 'creates projected entry' do
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

  describe 'ProjectedEntry_v1.update' do
    it 'updates a projected entry' do
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

  describe 'ProjectedEntry_v1.delete' do
    it 'deletes a projected entry' do
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

  describe 'Account_v1.delete' do
    it 'sets the deleted_at column' do
      account = Account.make!

      data = { id: account.id }
      post :bulk, [
        { resource: 'Account_v1', action: 'delete', id: account.id, refrence: 'delete account', data: data }
      ].to_json

      expect(account.reload.deleted_at).to_not be_nil
    end

    it 'updates the record' do
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

  describe 'LedgerSummary_v1.read' do
    it 'responds with collection' do
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
