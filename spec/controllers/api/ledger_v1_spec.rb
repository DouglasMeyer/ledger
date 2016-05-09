require 'rails_helper'

describe API::Ledger_v1 do
  let(:admin){ { provider: 'tester', email: 'admin@tester.com' } }
  before { ENV['ADMIN_AUTH'] = admin.to_json }
  after do
    extra_ledgers = TenantLedger.all - [ 'template_ledger' ]
    extra_ledgers.each{|ledger| TenantLedger.delete(ledger) }
  end
  let(:user){ admin }

  describe "read" do
    let(:response){ API::Ledger_v1.read({ 'user' => user }) }

    it_behaves_like "an admin only action"

    it "responds with collection" do
      TenantLedger.create('test_one')
      TenantLedger.create('test_two')

      expect(response[:data]).to eq(
        TenantLedger.all
      )
    end
  end

  describe "create" do
    let(:response){ API::Ledger_v1.create({ 'user' => user, 'data' => 'ledger_name' }) }

    it_behaves_like "an admin only action"

    it "creates the ledger" do
      expect(TenantLedger).to receive(:create).with('ledger_name')
      expect(response[:data]).to eq('ledger_name')
    end
  end
end
