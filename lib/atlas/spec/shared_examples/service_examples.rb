# frozen_string_literal: true

require 'rspec/core/shared_context'

module Atlas
  module Spec
    module SharedExamples
      module ServiceExamples
        extend RSpec::Core::SharedContext

        shared_examples_for('a service') do
          it { is_expected.to be_a(Atlas::Service::ServiceResponse) }
          it { expect { subject }.to_not raise_error }
        end

        shared_examples_for('a service with successful response') do
          it_behaves_like 'a service'
          it { is_expected.to be_success }
          it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::NONE) }
        end

        shared_examples_for('a service with failure response') do
          it_behaves_like 'a service'
          it { is_expected.to_not be_success }
          it { expect(subject.data).to be_a(Hash) }
          it { expect(subject.message).to be_a(String) }
          it { expect(subject.message).to_not be_empty }
          it { expect(subject.code).to_not eq(Atlas::Enum::ErrorCodes::NONE) }
        end

        shared_examples_for('a service with valid params') do
          context 'with context' do
            let(:context) { build(:request_context) }
            it_behaves_like 'a service with successful response'
          end

          context 'without context' do
            let(:context) { nil }
            it_behaves_like 'a service'
          end
        end

        shared_examples_for('a service with invalid params') do
          context 'with context' do
            let(:context) { build(:request_context) }
            it_behaves_like 'a service with failure response'
          end

          context 'without context' do
            let(:context) { nil }
            it_behaves_like 'a service with failure response'
          end
        end

        shared_examples_for('a paginated service with valid params') do
          context 'with context' do
            let(:context) { build(:request_context) }
            it_behaves_like 'a service with successful response'
            it { expect(subject.data).to be_a(Atlas::Service::Mechanism::Pagination::QueryResult) }
            it { expect(subject.data.results).to be_a(Array) }
          end

          context 'without context' do
            let(:context) { nil }
            it_behaves_like 'a service'
          end
        end
      end
    end
  end
end
