RSpec.describe BadgedIds::BadgedId do
  let(:model) { double('Model', primary_key: :id) }
  let(:badge) { :foo }
  let(:options) { {} }

  subject { described_class.new(model, badge, **options) }

  describe ".new" do
    it "sets the badge as a string" do
      expect(subject.badge).to eq("foo")
    end

    it "sets the id_field to the model's stringified primary key" do
      expect(subject.id_field).to eq("id")
    end

    context "when the id_field is passed as an option" do
      let(:options) { { id_field: "custom_id" } }

      it "sets the id_field to the provided stringified value" do
        expect(subject.id_field).to eq("custom_id")
      end
    end

    it "allows to override overridable configs, ignores non-overridable configs" do
      options = {
        alphabet: "abc",
        delimiter: "-", # non-overridable
        implicit_order_column: :created_at,
        minimum_length: 10,
        max_generation_attempts: 5,
        skip_uniqueness_check: true
      }
      badged_id = described_class.new(model, badge, **options)

      expected_values = options.tap do |options|
        options[:delimiter] = "_" # global config
      end
      expected_values.each do |key, value|
        expect(badged_id.config.public_send(key)).to eq(value)
      end
    end
  end

  describe '#generate_id' do
    it 'generates an ID with the badge, the delimiter and a random part' do
      generated_id = subject.generate_id

      expect(generated_id).to match(/^foo_([a-zA-Z0-9]{24})$/)
    end

    it 'validates the configuration before generating the ID' do
      expect(subject).to receive(:validate!)

      subject.generate_id
    end
  end

  describe '#validate!' do
    it 'validates the overriden configuration' do
      expect(subject.config).to receive(:validate!)

      subject.validate!
    end

    describe "validates combination of 'badge' and 'delimiter'" do
      context "when both values have no overlapping characters" do
        it "returns true" do
          expect(subject.validate!).to eq(true)
        end
      end

      context "when both values have overlapping characters" do
        it "raises an error" do
          subject = described_class.new(model, "_")

          expect {
            subject.validate!
          }.to raise_error(BadgedIds::ConfigError, "Badge and delimiter cannot share characters: `_`.")
        end
      end
    end
  end
end
