RSpec.describe Atlas::API::Middleware::ContextAcquirerMiddleware, type: :middleware do
  let(:rack_app) { Mock::RackApp[] }

  describe '#initialize' do
    subject { Atlas::API::Middleware::ContextAcquirerMiddleware.new(rack_app, **params) }

    context 'when params are empty' do
      let(:params) { {} }

      it { expect { subject }.to_not raise_error }
    end

    context 'when params are not nil' do
      let(:params) { { component: 'SPEC COMPONENT' } }

      it { expect { subject }.to_not raise_error }
    end
  end

  describe '#call' do
    subject { Atlas::API::Middleware::ContextAcquirerMiddleware.new(rack_app, **params).call(env) }

    context 'when there is no request context in env' do
      let(:env) { {} }

      context 'when params are empty' do
        let(:params) { {} }

        it { expect { subject }.to_not raise_error }
        it do
          expect(rack_app).to receive(:call)
          subject
        end
      end

      context 'when params are not empty' do
        let(:params) { { component: 'SPEC COMPONENT' } }

        it { expect { subject }.to_not raise_error }
      end
    end

    context 'when there is a request context in env' do
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

      context 'when params are empty' do
        let(:params) { {} }

        it { expect { subject }.to_not raise_error }
        it do
          expect(rack_app).to receive(:call)
          subject
        end
        it { expect { subject }.to_not change(env[:request_context], :component) }
      end

      context 'when params are not empty' do
        let(:initial_value) { 'INITIAL VALUE' }
        let(:final_value) { 'SPEC COMPONENT' }
        let(:params) { { component: final_value } }

        it { expect { subject }.to_not raise_error }
        it { expect { subject }.to change { env[:request_context].component }.from(initial_value).to(final_value) }
      end
    end
  end
end
