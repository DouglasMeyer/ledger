shared_examples_for "an admin only action" do
  context "for an admin" do
    let(:user){ admin }

    it "does not return an error" do
      expect(response).not_to have_key :errors
    end
  end

  context "for a non-admin" do
    let(:user){ {} }

    it "returns an error" do
      expect(response[:errors]).to eq([
        "Only the admin is authorized to be here"
      ])
    end
  end
end
