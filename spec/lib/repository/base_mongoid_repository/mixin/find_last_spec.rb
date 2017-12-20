# frozen_string_literal: true

RSpec.describe Atlas::Repository::BaseMongoidRepository::Mixin::FindLast, type: :repository do

  describe '#find_last' do
    let(:incluing_class) do
      Class.new do
        include Atlas::Repository::BaseMongoidRepository::Mixin::FindLast
      end
    end

    let(:instance) { incluing_class.new }

    subject { instance.find_last(statements) }

    let(:statements) { { sorting: 'sort' } }
    let(:entity) { double(:entity) }
    let(:results) { [] }

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
      let(:results) { [] }
      it { is_expected.to be_falsey }
    end

    context 'when result returns more than one result' do
      let(:model_one) { double(:model) }
      let(:model_two) { double(:model) }
      let(:results) { [model_one, model_two] }

      context 'when has sorting on statements' do
        it 'transforms model to entity' do
          expect(instance).to receive(:model_to_entity).with(model_two)
          subject
        end
      end

      context 'when hasnst sorting on statements' do
        let(:statements) { {filtering: 'uuid:eq:x'} }

        it 'transforms model to entity' do
          expect(instance).to_not receive(:model_to_entity)
          subject
        end

        it { is_expected.to be_falsey }
      end
    end

    context 'when result returns exactly one result' do
      let(:model) { double(:model) }
      let(:results) { [model] }
      it { is_expected.to be(entity) }

      it 'transforms model to entity' do
        expect(instance).to receive(:model_to_entity).with(model)
        subject
      end
    end
  end
end
