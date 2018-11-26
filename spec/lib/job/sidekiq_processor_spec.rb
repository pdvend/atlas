RSpec.describe Atlas::Job::SidekiqProcessor, type: :entity do
  describe '.new' do
    subject { described_class.new.perform(params) }
    let(:params) do
      {
        job: job,
        payload: payload
      }
    end

    let(:job) { double('fakejob') }
    let(:payload) { { foo: :bar } }
    let(:notifier) { double('notifier') }

    before do
      allow(notifier).to receive(:send_error).and_return(true)
      allow(notifier).to receive(:send_message).and_return(true)
      allow(Atlas::Service::Notifier::Webhook).to receive(:new).with([nil,nil]).and_return(notifier)
    end

    context 'with valid params' do
      it { expect { subject }.to_not raise_error }
      it { is_expected.to be_truthy }
    end

    context 'with invalid params' do
      before do
        allow(job).to receive(:perform).and_raise("boom")
      end

      let(:params) { 11 }
      it { expect { subject }.to_not raise_error }
      it { is_expected.to be_truthy }
    end
  end
end
