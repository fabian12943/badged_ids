RSpec.describe BadgedIds do
  after do
    BadgedIds::Registry.models.clear
    described_class.config.reset_to_defaults!
  end

  describe ".config" do
    it "returns the current configuration when no block is given" do
      expect(described_class.config).to be_a(BadgedIds::Configuration)
    end

    it "yields the configuration object when a block is given" do
      described_class.config do |config|
        config.alphabet = "abc"
        config.delimiter = "-"
      end

      expect(described_class.config.alphabet).to eq("abc")
      expect(described_class.config.delimiter).to eq("-")
    end
  end

  describe ".find" do
    it "finds a record by badged ID" do
      model =  Class.new(ActiveRecord::Base) do
        self.table_name = "records_with_string_id"
        has_badged_id :foo
      end

      record = model.create!

      expect(record.id).to match(/^foo_([a-zA-Z0-9]{24})$/)
      expect(BadgedIds.find(record.id)).to eq(record)
    end
  end
end
