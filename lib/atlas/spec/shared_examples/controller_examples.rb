# frozen_string_literal: true

require 'rspec/core/shared_context'

module Atlas
  module Spec
    module SharedExamples
      module ControllerExamples
        extend RSpec::Core::SharedContext

        shared_examples_for('controller common specs') do
          context 'with valid params' do
            context 'when service returns success' do
              it_behaves_like 'a controller that invoke service and return success'
            end
      
            it_behaves_like 'a controller returns authorization error'
            it_behaves_like 'a controller returns failure'
          end
        end

        shared_examples_for('index controller common specs') do
          context 'with a valid request' do
            let(:service_mock) { Atlas::Spec::Mock::Service.new(service_response) }
            let(:service_response) { build(:service_response, :success, data: paginated_response) }
            let(:paginated_response) { build(:query_result, results: []) }
            
            it_behaves_like 'a controller that invoke service and return success'
            it_behaves_like 'a controller returns authorization error'
            it_behaves_like 'a controller returns failure'

            context 'correct response' do
              it { is_expected.to include(200) }
              it { expect(response[1]).to include('Total') }
              it { expect(response[1]).to include('Per-Page') }
            end
          end
        end

        shared_examples_for('show controller common specs') do
          context 'with a valid request' do
            let(:service_mock) { Atlas::Spec::Mock::Service.new(service_response) }
            let(:service_response) { build(:service_response, :success, data: query_result) }
            let(:query_result) { build(:query_result, results: service_results) }
            
            it_behaves_like 'a controller returns authorization error'
            it_behaves_like 'a controller returns failure'

            context 'when service returns success' do
              context 'invoke service' do
                it do
                  expect { subject }
                    .to invoke(service_mock, :execute)
                    .with(any_args, expected_invoke_params)
                end
              end

              context 'when any result' do
                it { expect(JSON.parse(subject[2].first)['uuid']).to eq(uuid) }
              end
      
              context 'when empty result' do
                let(:query_result) { build(:query_result, results: []) }
      
                it { expect(subject[0]).to eq(404) }
                it { expect(subject[2].first[:code]).to eq(App::Enum::ErrorCodes::RESOURCE_NOT_FOUND) }
              end
            end
          end
        end

        shared_examples_for('a controller that returns success') do
          it { expect(subject[0]).to be_between(200, 299).inclusive }
        end

        shared_examples_for('a controller that returns paginated response') do
          it_behaves_like 'a controller that returns success'
          it { expect(subject[1]).to include('Total') }
          it { expect(subject[1]).to include('Per-Page') }
        end

        shared_examples_for('a controller that returns failure code') do
          it { expect(subject[0]).to be > 299 }
        end

        shared_examples_for('a controller that is unauthorized code') do
          it { expect(subject[0]).to eq(403) }
        end


        shared_examples_for('a controller that invoke service and return success') do
          let(:service_mock) { Atlas::Spec::Mock::Service.new(service_response) }
          let(:service_response) { build(:service_response, :success) }

          context 'invoke service' do
            it do
              expect { subject }
                .to invoke(service_mock, :execute)
                .with(any_args, expected_invoke_params)
            end
          end

          it_behaves_like 'a controller that returns success'
        end

        shared_context('a controller returns authorization error') do
          let(:service_mock) { Atlas::Spec::Mock::Service.new(service_response) }
          let(:service_response) { build(:service_response, :unauthorized) }
          it_behaves_like 'a controller that is unauthorized code'
        end

        shared_context('a controller returns failure') do
          let(:params) { { invalid: :param } }
          let(:service_response) { build(:service_response, :failure) }
          let(:service_mock) { Atlas::Spec::Mock::Service.new(service_response) }
          it_behaves_like 'a controller that returns failure code'
        end
      end
    end
  end
end
