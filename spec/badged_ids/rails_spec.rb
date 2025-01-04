RSpec.describe BadgedIds::Rails do
  let(:badge) { :foo }
  let(:options) { {} }
  let!(:model) { create_test_model(badge, **options) }

  after do
    BadgedIds::Registry.models.clear
  end

  def create_test_model(badge, **options)
    expect(BadgedIds::BadgedId).to receive(:new).with(anything, badge, **options).and_call_original
    expect(BadgedIds::Registry).to receive(:register).with(badge, anything).and_call_original

    Class.new(ActiveRecord::Base) do
      self.table_name = "records_with_string_id"
      has_badged_id badge, **options
    end
  end

  describe '.has_badged_id' do
    it 'sets the _badged_id class attribute' do
      expect(model._badged_id).to be_an_instance_of(BadgedIds::BadgedId)
    end

    it 'registers the model in the Registry' do
      expect(BadgedIds::Registry.models[badge.to_s]).to eq(model)
    end

    it 'defines the generate_badged_id method' do
      expect(model.respond_to?(:generate_badged_id)).to be true
    end

    context 'when a custom implicit_order_column is provided' do
      let(:options) { { implicit_order_column: :created_at } }

      context 'when the model does not have an implicit_order_column already' do
        it 'sets the implicit_order_column' do
          expect(model.implicit_order_column).to eq(:created_at)
        end
      end

      context 'when the model already has an implicit_order_column set' do
        let!(:model) do
          Class.new(ActiveRecord::Base) do
            self.table_name = "records_with_string_id"
            self.implicit_order_column = :updated_at

            has_badged_id :foo, implicit_order_column: :created_at
          end
        end

        it 'does not override the existing implicit_order_column' do
          expect(model.implicit_order_column).to eq(:updated_at)
        end
      end
    end
  end

  describe 'before_create callback' do
    let(:record) { model.new }

    before do
      expect(record.class).to receive(:generate_badged_id).and_return("foo_12345")
    end

    it 'generates an id and sets it for the id field' do
      expect { record.run_callbacks(:create) }.to change(record, :id).from(nil).to("foo_12345")
    end
  end

  describe '.generate_badged_id' do
    context 'when skip_uniqueness_check is set to true' do
      let(:options) { { skip_uniqueness_check: true } }

      it 'returns a single (potentially not unique) id' do
        expect(model._badged_id).to receive(:generate_id).once.and_call_original
        expect(model).not_to receive(:exists?)
        expect(model.generate_badged_id).to match(/^foo_[a-zA-Z0-9]{24}$/)
      end
    end

    context 'when skip_uniqueness_check is set to false' do
      let(:options) { { skip_uniqueness_check: false } }

      context 'when the generated id is unique' do
        before do
          expect(model._badged_id).to receive(:generate_id).once.and_call_original
          expect(model).to receive(:exists?).once.and_return(false)
        end

        it 'returns the generated id' do
          expect(model.generate_badged_id).to match(/^foo_[a-zA-Z0-9]{24}$/)
        end
      end

      context 'when the generated id is not unique' do
        context 'when the maximum number of attempts is not reached' do
          let(:options) { { skip_uniqueness_check: false, max_generation_attempts: 2 } }

          before do
            expect(model._badged_id).to receive(:generate_id).twice.and_call_original
            expect(model).to receive(:exists?).twice.and_return(true, false)
          end

          it 'retries until a unique id is generated' do
            expect(model.generate_badged_id).to match(/^foo_[a-zA-Z0-9]{24}$/)
          end
        end

        context 'when the maximum number of attempts is reached' do
          let(:options) { { skip_uniqueness_check: false, max_generation_attempts: 2 } }

          before do
            expect(model._badged_id).to receive(:generate_id).twice.and_call_original
            expect(model).to receive(:exists?).twice.and_return(true, true)
          end

          it 'raises an error' do
            expect {
              model.generate_badged_id
            }.to raise_error(BadgedIds::Error, <<~MESSAGE.squish
              Failed to generate a unique badged ID within 2 attempts.
              Consider increasing the minimum length or the unique characters in the alphabet.
            MESSAGE
            )
          end
        end
      end
    end
  end
end
