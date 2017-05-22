RSpec.describe Atlas::Service::Mechanism::Sorting do
  describe '.sorting_params' do
    subject { Atlas::Service::Mechanism::Sorting.sorting_params(params, entity) }
    let(:entity) { Mock::Entity[:name,:application_key] }

    context 'when have asc attributes' do
      let(:params) { 'name' }
      it { is_expected.to eq([{ field: 'name', direction: :asc }]) }
    end

    context 'when have desc attributes' do
      let(:params) { '-name' }
      it { is_expected.to eq([{ field: 'name', direction: :desc }]) }
    end

    context 'when have desc and asc attributes' do
      let(:params) { '-name,application_key' }

      it { is_expected.to include(field: 'name', direction: :desc) }
      it { is_expected.to include(field: 'application_key', direction: :asc) }
    end
  end
end
