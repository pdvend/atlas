RSpec.describe Atlas::Service::Mechanism::ServiceResponseFormatter do
  describe '.format' do
    let(:entity) { Atlas::Spec::Mock::Entity[:name, :value] }
    let(:partner_params) { { page: 1, count: 3 } }
    let(:page_limit) { 25 }
    let(:data) { { total: 2, response: [1, 2] } }
    subject { Atlas::Service::Mechanism::ServiceResponseFormatter.new.format(repository, repository_method, format_params) }
    let(:repository) { Atlas::Spec::Mock::Repository }
    let(:repository_method) { :find_paginated }
    let(:repository_response) { Atlas::Repository::RepositoryResponse.new(data: data, success: true) }
    let(:constraints) { [[:and, :name, :eq, 'name']] }
    before { allow(repository).to receive(repository_method).and_return(repository_response) }

    context 'when repository_response is successs' do
      let(:format_params) { { query_params: partner_params, page_limit: page_limit, entity: entity } }

      it { expect(subject.data).to be_a(Atlas::Service::Mechanism::Pagination::QueryResult) }
      it { expect(subject.data.total).to eq(2) }
      it { expect(subject.data.per_page).to eq(3) }
      it { expect(subject.data.results).to be_a(Array) }
    end

    context 'when method not is transform' do
      let(:format_params) { { query_params: partner_params, page_limit: page_limit, entity: entity } }

      it { expect(subject.data).to be_a(Atlas::Service::Mechanism::Pagination::QueryResult) }
      it { expect(subject.data.total).to eq(2) }
      it { expect(subject.data.per_page).to eq(3) }
      it { expect(subject.data.results).to be_a(Array) }
    end

    context 'when contraints are informed' do
      let(:format_params) do
        {
          query_params: partner_params,
          page_limit: page_limit,
          entity: entity,
          constraints: constraints
        }
      end

      it 'data is a QueryResult' do
        expect(subject.data).to be_a(Atlas::Service::Mechanism::Pagination::QueryResult)
      end

      it 'receive correct params' do
        expect(repository).to receive(repository_method).with(
          pagination: { limit: 3, offset: 0 },
          sorting: [],
          filtering: constraints
        )

        subject
      end
    end

    context 'when method is transform' do
      let(:repository_method) { :transform }
      let(:transformation_params) { "#{operation}:#{field}" }
      let(:data) { 2 }
      let(:operation) { :sum }
      let(:field) { :value }
      let(:partner_params) { { transform: transformation_params, page: 1, count: 3 } }
      let(:format_params) do
        {
          query_params: partner_params,
          constraints: constraints,
          page_limit: page_limit,
          entity: entity
        }
      end

      it { expect(subject.data).to be_a(Atlas::Service::Mechanism::Transformation::TransformResult) }
      it { expect(subject.data[:operation]).to eq(operation) }
      it { expect(subject.data[:field]).to eq(field) }
      it { expect(subject.data[:result]).to eq(data) }

      it 'receive correct params' do
        expect(repository).to receive(repository_method).with(
          sorting: [],
          filtering: constraints,
          transform: { operation: operation, field: field }
        )

        subject
      end
    end
  end
end
