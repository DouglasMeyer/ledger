require 'rails_helper'

describe V3::PagesController, type: :controller do
  describe "#admin" do
    context "when an admin" do
      before do
        session[:auth_user] = { provider: 'doug_oauth', email: 'Douglas.Meyer@mail.com' }
        ENV['ADMIN_AUTH'] = session[:auth_user].to_json
        get :admin
      end

      it { expect(response).to have_http_status :ok }
    end

    context "when not an admin" do
      before do
        session[:auth_user] = { provider: 'doug_oauth', email: 'Katy.Meyer@mail.com' }
        ENV['ADMIN_AUTH'] = {}.to_json
        get :admin
      end

      it { expect(response).not_to have_http_status :ok }
    end
  end
end
