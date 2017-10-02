RSpec.describe Atlas::Service::Util::Slack, type: :service do
  describe '#notificate_slack' do
    subject { described_class.notificate_slack(message) }

    context 'notificate slack with a msg using http post' do
      let(:slack_hook_url) { 'http://someurl.com.br' }
      let(:message) { 'Hello darkness my old friend' }

      before do
        stub_const("#{described_class}::WEBHOOK_URL", slack_hook_url)
        stub_request(:post, slack_hook_url).with(message)
      end

      it { subject }
    end
  end
end
