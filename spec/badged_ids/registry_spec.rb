RSpec.describe BadgedIds::Registry do
  let(:badge) { :foo }
  let(:model) { double("Model", to_s: "Model") }
  let(:different_model) { double("Different Model", to_s: "DifferentModel") }

  after do
    described_class.models.clear
  end

  describe ".register" do
    context "when the badge is not already registered with a model" do
      it "registers the badge with the model" do
        expect {
          described_class.register(badge, model)
        }.to change { described_class.models[badge.to_s] }.from(nil).to(model)
      end
    end

    context "when the badge is already registered with the same model" do
      before do
        described_class.register(badge, model)
      end

      it "does not raise an error" do
        expect {
          described_class.register(badge, model)
        }.not_to change { described_class.models[badge.to_s] }
      end
    end

    context "when the badge is already registered with a different model" do
      before do
        described_class.register(badge, different_model)
      end

      it "raises an error" do
        expect {
          described_class.register(badge, model)
        }.to raise_error(BadgedIds::RegistryError, "Badge `foo` is already assigned to `DifferentModel`.")
      end
    end
  end

  describe ".find_model" do
    context 'when the badge is registered with a model' do
      before do
        described_class.register(badge, model)
      end

      it 'returns the model associated with the badge' do
        expect(described_class.find_model(badge)).to eq(model)
      end
    end

    context 'when the badge is not registered with a model' do
      before do
        described_class.register(:bar, different_model)
      end

      it 'raises an error' do
        expect {
          described_class.find_model(badge)
        }.to raise_error(BadgedIds::RegistryError, "No model with the badge `foo` registered. Available badges are: bar.")
      end
    end
  end

  describe ".registered_badges" do
    it "returns all registered badges" do
      described_class.register(badge, model)
      described_class.register(:bar, different_model)

      expect(described_class.registered_badges).to eq(%w[foo bar])
    end

    it "returns an empty array when no badges are registered" do
      expect(described_class.registered_badges).to eq([])
    end
  end
end
