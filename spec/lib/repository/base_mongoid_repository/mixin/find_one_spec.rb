# frozen_string_literal: true

RSpec.describe Atlas::Repository::BaseMongoidRepository::Mixin::FindOne, type: :repository do

  describe '#find_one' do
    let(:incluing_class) do
      Class.new do
        include Atlas::Repository::BaseMongoidRepository::Mixin::FindOne
      end
    end

    let(:instance) { incluing_class.new }

    subject { instance.find_one(statements) }

    let(:statements) { double(:statements) }
    let(:entity) { double(:entity) }
    let(:results) { { query: 'foo', count: 1} }

    before do
      allow(instance).to receive(:wrap).and_yield
      allow(instance).to receive(:apply_statements).and_return(results)
      allow(instance).to receive(:model_to_entity).and_return(entity)
    end

    it 'applies statements' do
      expect(instance).to receive(:apply_statements).with(statements)
      subject
    end

    context 'when result returns no results' do
    let(:results) { { query: [], count: 0} }
      it { is_expected.to be_falsey }
    end

    context 'when result returns more than one result' do
      let(:results) { { query: [double(:model), double(:model)], count: 2 }}
      it { is_expected.to be_falsey }
    end

    context 'when result returns exactly one result' do
      let(:model) { double(:model) }
      let(:results) { { query: [model], count: 1 } }
      it { is_expected.to be(entity) }

      it 'transforms model to entity' do
        expect(instance).to receive(:model_to_entity).with(model)
        subject
      end
    end
  end
end
