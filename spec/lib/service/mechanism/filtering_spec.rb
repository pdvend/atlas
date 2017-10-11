# frozen_string_literal: true

RSpec.describe Atlas::Service::Mechanism::Filtering do
  describe '.sorting_params' do
    subject { Atlas::Service::Mechanism::Filtering.filter_params(params, entity) }
    let(:entity) { Atlas::Spec::Mock::Entity[:name] }

    context 'with valid query but attrbiute does not exist' do
      let(:params) { 'names:gte:tests' }
      it { is_expected.to eq([]) }
    end

    context 'when have no conjunction' do
      let(:params) { 'name:gte:test' }
      it { is_expected.to eq([[:and, :name, :gte, 'test']]) }
    end

    context 'when have OR conjunction' do
      let(:params) { 'name:gt:test,or:name:eq:test' }
      it { is_expected.to include([:and, :name, :gt, 'test']) }
      it { is_expected.to include([:or, :name, :eq, 'test']) }
    end

    context 'when have AND and OR conjunction' do
      let(:params) { 'name:gt:test,or:name:eq:test,and:name:like:st' }
      it { is_expected.to include([:and, :name, :gt, 'test']) }
      it { is_expected.to include([:and, :name, :like, 'st']) }
      it { is_expected.to include([:or, :name, :eq, 'test']) }
    end

    context 'when have a subparameter' do
      before { entity.subparameters(subparameters) }
      context 'when is integer' do
        let(:subparameters) { { 'metadata.number': :to_i } }
        let(:params) { 'metadata.number:gt:1' }
        it { is_expected.to include([:and, :'metadata.number', :gt, 1]) }
      end

      context 'when is string' do
        let(:subparameters) { { 'metadata.name': :to_s } }
        let(:params) { 'metadata.name:gt:teste' }
        it { is_expected.to include([:and, :'metadata.name', :gt, 'teste']) }
      end
    end
  end
end
