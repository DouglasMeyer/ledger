require 'rails_helper'

describe API::User_v1 do
  let(:admin){ { provider: 'tester', email: 'admin@tester.com' } }
  before { ENV['ADMIN_AUTH'] = admin.to_json }
  let(:user){ admin }

  describe "read" do
    let(:response){ API::User_v1.read({ 'user' => user }) }

    it_behaves_like "an admin only action"

    it "responds with collection" do
      User.make!
      User.make!

      expect(response[:records].pluck(:id, :name)).to eq(
        User.all.pluck(:id, :name)
      )
    end
  end

  describe "create" do
    let(:data){ { provider: 'google_oauth2', email: 'person@gmail.com', ledger: 'person_ledger' } }
    let(:response){ API::User_v1.create({ 'user' => user, 'data' => data }) }

    it_behaves_like "an admin only action"

    it "creates the user" do
      response
      expect(response[:records].first.id).to eq(
        User.last.id
      )
    end
  end
end
