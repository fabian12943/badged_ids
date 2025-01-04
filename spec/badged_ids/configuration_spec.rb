RSpec.describe BadgedIds::Configuration do
  subject { described_class.new }

  describe ".new" do
    it "sets default values for all configs" do
      expect(subject.alphabet).to eq("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890")
      expect(subject.delimiter).to eq('_')
      expect(subject.minimum_length).to eq(24)
      expect(subject.implicit_order_column).to eq(nil)
      expect(subject.max_generation_attempts).to eq(1)
      expect(subject.skip_uniqueness_check).to eq(false)
    end
  end

  describe '#validate!' do
    describe "validates 'alphabet'" do
      context "when the value is valid" do
        it "returns true" do
          [ "ab12+-", "ab", "12", "+-" ].each do |valid_value|
            subject.alphabet = valid_value

            expect(subject.validate!).to eq(true)
          end
        end
      end

      context "when the value is blank" do
        it "raises an error" do
          [ "", " ", nil ].each do |blank_value|
            subject.alphabet = blank_value

            expect {
              subject.validate!
            }.to raise_error(BadgedIds::ConfigError, "Alphabet cannot be blank.")
          end
        end
      end

      context "when the value contains a single character" do
        it "raises an error" do
          subject.alphabet = "a"

          expect {
            subject.validate!
          }.to raise_error(BadgedIds::ConfigError, "Alphabet must contain at least two unique characters.")
        end
      end

      context "when the value contains only one unique character" do
        it "raises an error" do
          subject.alphabet = "aa"

          expect {
            subject.validate!
          }.to raise_error(BadgedIds::ConfigError, "Alphabet must contain at least two unique characters.")
        end
      end
    end

    describe "validates 'delimiter'" do
      context "when the value is valid" do
        it "returns true" do
          [ "_", "-", "---" ].each do |valid_value|
            subject.delimiter = valid_value

            expect(subject.validate!).to eq(true)
          end
        end
      end

      context "when the value is blank" do
        it "raises an error" do
          [ "", " ", nil ].each do |blank_value|
            subject.delimiter = blank_value

            expect {
              subject.validate!
            }.to raise_error(BadgedIds::ConfigError, "Delimiter cannot be blank.")
          end
        end
      end
    end

    describe "validates combination of 'alphabet' and 'delimiter'" do
      context "when both values have no overlapping characters" do
        it "returns true" do
          subject.alphabet = "abc"
          subject.delimiter = "_"

          expect(subject.validate!).to eq(true)
        end
      end

      context "when both values have overlapping characters" do
        it "raises an error" do
          subject.alphabet = "abc_"
          subject.delimiter = "a_"

          expect {
            subject.validate!
          }.to raise_error(BadgedIds::ConfigError, "Alphabet and delimiter cannot share characters: `a`, `_`.")
        end
      end
    end

    describe "validates 'minimum_length'" do
      context "when the value is greater than 0" do
        it "returns true" do
          subject.minimum_length = 1

          expect(subject.validate!).to eq(true)
        end
      end

      context "when the value is less than 1" do
        it "raises an error" do
          subject.minimum_length = 0

          expect {
            subject.validate!
          }.to raise_error(BadgedIds::ConfigError, "Minimum length must be greater than 0.")
        end
      end
    end

    describe "validates 'max_generation_attempts'" do
      context "when the value is greater than 0" do
        it "returns true" do
          subject.max_generation_attempts = 1

          expect(subject.validate!).to eq(true)
        end
      end

      context "when the value is less than 1" do
        it "raises an error" do
          subject.max_generation_attempts = 0

          expect {
            subject.validate!
          }.to raise_error(BadgedIds::ConfigError, "Max generation attempts must be greater than 0.")
        end
      end
    end
  end
end
