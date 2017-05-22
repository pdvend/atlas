RSpec.describe Atlas::Service::Mechanism::Filtering do
  describe '.sorting_params' do
    subject { Atlas::Service::Mechanism::Filtering.filter_params(params, entity) }
    let(:entity) { Mock::Entity[:name] }

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
  end
end
