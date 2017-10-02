RSpec.describe Atlas::Service::Util::Slack, type: :service do
  describe '#send' do
    subject { described_class.new(slack_hook_url).send(message) }

    context 'notificate slack with a msg using http post' do
      let(:slack_hook_url) { 'http://someurl.com.br' }
      let(:message) { 'Hello darkness my old friend' }

      before do
        stub_request(:post, slack_hook_url).with(body: "{\"text\":\"#{message}\"}")
      end

      it { subject }
    end
  end
end
