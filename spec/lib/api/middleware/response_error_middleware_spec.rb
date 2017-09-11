RSpec.describe Atlas::API::Middleware::ResponseErrorMiddleware, type: :middleware do
  describe '#call' do
    subject { described_class.new(app).call(env) }
    let(:app) { Atlas::Spec::Mock::RackApp[] }
    let(:env) { double('env') }
    let(:call_response) { [status, headers, body] }
    let(:headers) { { foor: 'bar' } }
    let(:body) { double('body', body: 'Some content') }
    let(:formated_error) do
      { code: code, message: body.body, errors: { } }.to_json
    end
    before { allow(app).to receive(:call).and_return(call_response) }

    context 'when status is 404' do
      let(:status) { 404 }
      let(:code) { Atlas::Enum::ErrorCodes::ROUTE_NOT_FOUND }
      it { expect(subject).to eq([status, {}, [formated_error]]) }
    end

    context 'when status is 500' do
      let(:status) { 500 }
      let(:code) { Atlas::Enum::ErrorCodes::INTERNAL }
      it { expect(subject).to eq([status, {}, [formated_error]]) }
    end

    context 'when status is 599' do
      let(:status) { 599 }
      let(:code) { Atlas::Enum::ErrorCodes::INTERNAL }
      it { expect(subject).to eq([status, {}, [formated_error]]) }
    end

    context 'when status is 200' do
      let(:status) { 200 }
      it { expect(subject).to eq([status, headers, body]) }
    end
  end
end
