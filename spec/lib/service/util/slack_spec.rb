RSpec.describe Atlas::Service::Util::Slack, type: :service do
  before do
    stub_request(:post, slack_hook_url)
  end

  let(:slack_hook_url) { 'http://someurl.com.br' }

  describe '#send_message' do
    subject { described_class.new(slack_hook_url).send_message(message) }

    let(:message) { { text: 'Hello darkness my old friend' } }

    it 'calls slack' do
      subject
      expect(a_request(:post, slack_hook_url).with(body: message.to_json)).to have_been_made
    end
  end

  describe '#send_error' do
    subject { described_class.new(slack_hook_url).send_error(error, context, tags) }

    let(:error) { double(:error, message: 'fake message', backtrace: ['foo'] * 15) }
    let(:context) { build(:request_context) }
    let(:tags) { %i[foo bar] }
    let(:message) { { text: expected_text } }
    let(:expected_text) do
      "[` #{Time.now.iso8601} `][` foo `][` bar `] *Ocorreu um erro!*\n" \
      "Contexto: `#{context.to_json}`\n" \
      "Mensagem: `fake message`\n" \
      "Stacktrace:\n```\nfoo\nfoo\nfoo\nfoo\nfoo\nfoo\nfoo\nfoo\nfoo\nfoo\n```"
    end

    before do
      Timecop.freeze(Time.utc(2017, 10, 10, 07, 20, 03))
    end

    require 'byebug'

    it 'calls slack' do
      subject
      expect(a_request(:post, slack_hook_url).with(body: message.to_json)).to have_been_made
    end
  end
end
