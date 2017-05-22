RSpec.describe Atlas::Service::Mechanism::Pagination do
  describe '.paginate_params' do
    subject { Atlas::Service::Mechanism::Pagination.paginate_params(params) }

    context 'when count is bigger than per_page' do
      let(:params) { { count: 30, page_limit: 25, page: 1 } }
      it { is_expected.to eq(limit: 25, offset: 0) }
    end

    context 'when count is not bigger than per_page' do
      let(:params) { { count: 20, page_limit: 25, page: 1 } }
      it { is_expected.to eq(limit: 20, offset: 0) }
    end

    context 'when page is bigger than one' do
      let(:params) { { count: 20, page_limit: 25, page: 2 } }
      it { is_expected.to eq(limit: 20, offset: 20) }
    end
  end
end
