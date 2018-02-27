# frozen_string_literal: true

RSpec.describe Atlas::Repository::BaseMongoidRepository, type: :repository do
  before do
    allow(model).to receive(:order).and_return(model)
    allow(model).to receive(:where).and_return(model)
  end

  let(:model) { double('model', fields: { field: field }) }
  let(:entity) { double('entity') }

  describe '#transform' do
    subject { described_class.new(model: model, entity: entity).transform(statements) }

    let(:statements) do
      {
        filtering: constraints,
        transform: { operation: operation, field: field }
      }
    end
    let(:field) { :value }
    let(:constraints) { [[:and, :name, :eq, 'some_name']] }

    context 'when operation is sum' do
      let(:operation) { :sum }

      it do
        expect(model).to receive(:sum).with(field)
        subject
      end
    end

    context 'when operation is count' do
      let(:operation) { :count }

      it do
        expect(model).to receive(:count)
        subject
      end
    end
  end
end
