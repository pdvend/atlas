# frozen_string_literal: true

RSpec.describe Atlas::Service::Util::SearchService, type: :service do
  describe '#format' do
    subject do
      klass = Class.new
      klass.include(described_class)
      klass.new.send(:format, repository, params)
    end

    let(:params) { {} }
    let(:repository) { Atlas::Spec::Mock::Repository }

    before do
      allow_any_instance_of(Atlas::Service::Mechanism::ServiceResponseFormatter)
        .to receive(:format)
        .and_return(format_response)
    end

    let(:format_response) { build(:repository_response, :success) }

    context 'when formatter returns success' do
      it_behaves_like 'a service with successful response'
      it { expect(subject.data).to eq(format_response.data) }

      it 'call #find_paginated' do
        expect_any_instance_of(Atlas::Service::Mechanism::ServiceResponseFormatter)
          .to receive(:format).with(repository, :find_paginated, params)
        subject
      end
    end

    context 'when formatter returns failure' do
      let(:format_response) { build(:repository_response, :failure) }

      it_behaves_like 'a service with failure response'
    end

    context 'when include transform params' do
      let(:repository_method) { :transform }
      let(:params) { { query_params: { transform: 'operator:field' } } }

      it 'call #transform' do
        expect_any_instance_of(Atlas::Service::Mechanism::ServiceResponseFormatter)
          .to receive(:format).with(repository, :transform, params).and_return(format_response)
        subject
      end
    end
  end
end
