# frozen_string_literal: true

RSpec.describe Atlas::API::Middleware::ResponseTelemetryMiddleware, type: :middleware do
  describe '#initialize' do
    subject { Atlas::API::Middleware::ResponseTelemetryMiddleware.new(Atlas::Spec::Mock::RackApp[], params) }

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
        .new(Atlas::Spec::Mock::RackApp[body], telemetry_service)
        .call(env)
    end

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
        let(:expected_data) { { type: :http_response, data: { status: 200, length: 6 } } }

        it { expect { subject }.to_not raise_error }
        it do
          expect(telemetry_service).to receive(:execute).with(env[:request_context], expected_data)
          subject
        end
      end

      context 'when the body is a enumerable' do
        let(:body) { ['Enumerable'] }
        let(:expected_data) { { type: :http_response, data: { status: 200, length: 10 } } }

        it { expect { subject }.to_not raise_error }

        it do
          expect(telemetry_service).to receive(:execute).with(env[:request_context], expected_data)
          subject
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
