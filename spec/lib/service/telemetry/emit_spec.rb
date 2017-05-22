RSpec.describe Atlas::Service::Telemetry::Emit, type: :service do
  describe '#execute' do
    subject { described_class.new.execute(context, params) }
    let(:context) { build(:request_context) }

    context 'with valid params' do
      let(:params) { { type: :fake, data: { fake: :data } } }

      before do
        stub_request(:post, 'https://firehose.us-east-1.amazonaws.com/')
        allow($stdout).to receive(:puts)
      end

      it_behaves_like 'a service with valid params'
    end

    context 'with nil params' do
      let(:params) { nil }
      it_behaves_like 'a service with invalid params'
    end
  end
end
