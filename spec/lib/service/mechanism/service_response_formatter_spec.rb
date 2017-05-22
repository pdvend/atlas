RSpec.describe Atlas::Service::Mechanism::ServiceResponseFormatter do
  describe '.format' do
    let(:entity) { Mock::Entity[:name] }
    let(:partner_params) { { page: 1, count: 3 } }
    let(:page_limit) { 25 }
    let(:data) { [1, 2] }
    subject { Atlas::Service::Mechanism::ServiceResponseFormatter.new.format(format_params) { params } }

    context 'when params is a repository_response' do
      let(:format_params) { { query_params: partner_params, page_limit: page_limit, entity: entity } }
      let(:params) { Atlas::Repository::RepositoryResponse.new(data: data, success: true) }

      it { is_expected.to be_a(Atlas::Repository::RepositoryResponse) }
      it { expect(subject.data).to be_a(Atlas::Service::Mechanism::Pagination::QueryResult) }
      it { expect(subject.data.total).to eq(2) }
      it { expect(subject.data.per_page).to eq(limit: 3, offset: 0) }
      it { expect(subject.data.results).to be_a(Array) }
    end

    context 'when params is a any data should return the input params' do
      let(:format_params) { { query_params: partner_params, page_limit: page_limit, entity: entity } }
      let(:params) { OpenStruct.new(data: data) }

      it { is_expected.to be_a(params.class) }
      it { expect(subject.data).to eq(data) }
    end

    context 'when contraints are informed' do
      let(:constraints) { [[:and, :name, :eq, 'name']] }
      let(:format_params) do
        {
          query_params: partner_params,
          page_limit: page_limit,
          entity: entity,
          constraints: constraints
        }
      end
      let(:params) { Atlas::Repository::RepositoryResponse.new(data: data, success: true) }

      it do
        expect do |block|
          Atlas::Service::Mechanism::ServiceResponseFormatter.new.format(format_params) do |args|
            block.to_proc.call(args)
            params
          end
        end.to yield_with_args(
          pagination: { limit: 3, offset: 0 },
          sorting: [],
          filtering: constraints
        )
      end
    end
  end
end
