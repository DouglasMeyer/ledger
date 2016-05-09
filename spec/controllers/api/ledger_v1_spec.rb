require 'rails_helper'

describe API::Ledger_v1 do
  let(:admin){ { provider: 'tester', email: 'admin@tester.com' } }
  before { ENV['ADMIN_AUTH'] = admin.to_json }
  after do
    extra_ledgers = TenantLedger.all - [ 'template_ledger' ]
    extra_ledgers.each{|ledger| TenantLedger.delete(ledger) }
  end

  describe "read" do
    let(:response){ API::Ledger_v1.read({ 'user' => admin }) }

    it "responds with collection" do
      TenantLedger.create('test_one')
      TenantLedger.create('test_two')

      expect(response[:data]).to eq(
        TenantLedger.all
      )
    end

    context "for a non-admin" do
      let(:response){ API::User_v1.read({ 'user' => {} }) }

      it "returns an error" do
        expect(response[:errors]).to eq([
          "Only the admin is authorized to be here"
        ])
      end
    end
  end
end
