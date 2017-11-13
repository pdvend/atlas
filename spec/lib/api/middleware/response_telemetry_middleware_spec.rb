# frozen_string_literal: true

RSpec.describe Atlas::API::Middleware::ResponseTelemetryMiddleware, type: :middleware do
  describe '#initialize' do
    subject { Atlas::API::Middleware::ResponseTelemetryMiddleware.new(app, params) }
    let(:app) { Atlas::Spec::Mock::RackApp[] }

    context 'when params are empty' do
      let(:params) { {} }

      it { expect { subject }.to_not raise_error }
    end

    context 'when params are not empty' do
      let(:params) { { telemetry_service: double('telemetry_service') } }

      it { expect { subject }.to_not raise_error }
    end
  end

  describe '#call' do
    subject do
      Atlas::API::Middleware::ResponseTelemetryMiddleware
        .new(app, telemetry_service)
        .call(env)
    end
    let(:app) { Atlas::Spec::Mock::RackApp[body] }
    let(:telemetry_service) { double(:telemetry_service) }

    before { allow(telemetry_service).to receive(:execute) }

    context 'when there is a context in the env' do
      let(:env) do
        {
          request_context: Atlas::Service::RequestContext.new(
            time: Time.now.utc,
            component: 'INITIAL VALUE',
            caller: '10.0.0.1',
            transaction_id: SecureRandom.uuid,
            account_id: nil
          )
        }
      end

      context 'when the body is a proxy' do
        let(:body) { Rack::BodyProxy.new('Proxy!') }
        let(:expected_data) { { type: :http_response, data: { status: 200, length: 6, params: {}, request: ' ://::0' } } }

        it { expect { subject }.to_not raise_error }
        it do
          expect(telemetry_service).to receive(:execute).with(env[:request_context], expected_data)
          subject
        end
      end

      context 'when the body is a enumerable' do
        let(:body) { ['Enumerable'] }
        let(:expected_data) { { type: :http_response, data: { status: 200, length: 10, params: {}, request: ' ://::0' } } }

        it { expect { subject }.to_not raise_error }

        it do
          expect(telemetry_service).to receive(:execute).with(env[:request_context], expected_data)
          subject
        end
      end

      context 'when app raises error' do
        before do
          allow(exception).to receive(:backtrace).and_return(backtrace)
        end

        let(:app) { ->(*) { raise exception } }
        let(:exception) { RuntimeError.new('foobar') }
        let(:backtrace) { ['fake', 'backtrace'] }
        let(:body) { ['Enumerable'] }
        let(:expected_data) do
          {
            type: :http_response,
            data: {
              request: ' ://::0',
              status: nil,
              length: nil,
              params: {},
              exception: {
                class: 'RuntimeError',
                message: 'foobar',
                backtrace: backtrace
              }
            }
          }
        end

        it 'calls telemetry and re-raises the error' do
          expect(telemetry_service).to receive(:execute).with(env[:request_context], expected_data)
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when there is no context in the env' do
      let(:env) { {} }

      context 'when the body is a proxy' do
        let(:body) { Rack::BodyProxy.new('Proxy!') }

        it { expect { subject }.to_not raise_error }
        it do
          expect(telemetry_service).to_not receive(:execute)
          subject
        end
      end

      context 'when the body is a enumerable' do
        let(:body) { ['Enumerable'] }

        it { expect { subject }.to_not raise_error }
        it do
          expect(telemetry_service).to_not receive(:execute)
          subject
        end
      end
    end
  end
end
