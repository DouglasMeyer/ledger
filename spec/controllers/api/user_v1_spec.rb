require 'rails_helper'

describe API::User_v1 do
  let(:admin){ { provider: 'tester', email: 'admin@tester.com' } }
  before { ENV['ADMIN_AUTH'] = admin.to_json }

  describe "read" do
    let(:response){ API::User_v1.read({ 'user' => admin }) }

    it "responds with collection" do
      User.make!
      User.make!

      expect(response[:records].pluck(:id, :name)).to eq(
        User.all.pluck(:id, :name)
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
