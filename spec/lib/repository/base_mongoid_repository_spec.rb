RSpec.describe Atlas::Repository::BaseMongoidRepository, type: :repository do
  before do
    allow_any_instance_of(described_class).to receive(:model).and_return(model)
  end
  let(:model) { double('model', fields: {field: field}) } 
  let(:collection) { double('collection', sum: result) }
  let(:result) { 2 }

  describe '#transform' do
    subject { described_class.new.transform(statements) }
    let(:statements) do 
      {
        filtering: constraints,
        transform: { operation: operation, field: field }
      }
    end
    let(:operation) { 'sum' }
    let(:field) { 'value' }
    let(:constraints) { [[:and, :name, :eq, 'some_name']] }

    context 'when' do
      before do
        expect(model).to receive(:where).with({ name: 'some_name' }).and_return(collection)
      end

      it { expect(subject.data).to eq(result) }

      it do
        subject
      end
    end
  end
end
