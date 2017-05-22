RSpec.describe Atlas::API::Middleware::RequestContextMiddleware, type: :middleware do
  describe '#initialize' do
    subject { Atlas::API::Middleware::RequestContextMiddleware.new(Atlas::Spec::Mock::RackApp[]) }

    context 'when params are nil' do
      let(:params) { nil }

      it { expect { subject }.to_not raise_error }
    end

    context 'when params are not nil' do
      let(:params) { { component: 'SPEC COMPONENT' } }

      it { expect { subject }.to_not raise_error }
    end
  end

  describe '#call' do
    subject { Atlas::API::Middleware::RequestContextMiddleware.new(Atlas::Spec::Mock::RackApp[]).call(env) }

    let(:env) { {} }

    it { expect { subject }.to_not raise_error }
    it do
      subject
      expect(env).to have_key(:request_context)
    end
    it do
      subject
      expect(env[:request_context]).to be_a(Atlas::Service::RequestContext)
    end

    context 'when there is a header X-Telemetry-Caller' do
      let(:caller_component) { 'Caller Component' }
      let(:env) { { 'HTTP_X_TELEMETRY_CALLER' => caller_component } }

      it do
        subject
        expect(env[:request_context].caller).to eq(caller_component)
      end
    end

    context 'when there is a header X-Telemetry-Transaction-Id' do
      let(:transaction_id) { SecureRandom.uuid }
      let(:env) { { 'HTTP_X_TELEMETRY_TRANSACTION_ID' => transaction_id } }

      it do
        subject
        expect(env[:request_context].transaction_id).to eq(transaction_id)
      end
    end
  end
end
