RSpec.describe Atlas::Repository::BaseMongoidRepository, type: :repository do
  before do
    allow_any_instance_of(described_class).to receive(:model).and_return(model)
  end
  let(:model) { double('model', fields: { field: field }) }
  let(:collection) { double('collection') }

  describe '#transform' do
    subject { described_class.new.transform(statements) }
    let(:statements) do
      {
        filtering: constraints,
        transform: { operation: operation, field: field }
      }
    end
    let(:field) { :value }
    let(:constraints) { [[:and, :name, :eq, 'some_name']] }

    before do
      expect(model).to receive(:where).with(name: 'some_name').and_return(collection)
    end

    context 'when operation is sum' do
      let(:operation) { :sum }

      it do
        expect(collection).to receive(:sum).with(field)
        subject
      end
    end

    context 'when operation is count' do
      let(:operation) { 'count' }

      it do
        expect(collection).to receive(:count)
        subject
      end
    end
  end
end
