# frozen_string_literal: true

RSpec.describe Atlas::Service::Notifier::Slack, type: :service do
  before do
    stub_request(:post, slack_hook_url)
  end

  let(:slack_hook_url) { 'http://someurl.com.br' }

  before { allow(ENV).to receive(:[]).with('SERVER_ENV').and_return(server) }
  let(:server) { 'SERVER' }

  describe '#send_message' do
    subject { described_class.new(slack_hook_url).send_message(params) }
    let(:params) { { text: message } }
    let(:message) { 'Hello darkness my old friend.' }
    let(:body) { { text: "[`#{server}`] #{message}" } }

    it 'calls slack' do
      subject
      expect(a_request(:post, slack_hook_url).with(body: body.to_json)).to have_been_made
    end

    context 'when extra params' do
      let(:params) { { text: message, username: username, channel: channel } }
      let(:username) { 'username' }
      let(:channel) { '#channel' }
      let(:body) { { text: "[`#{server}`] #{message}", username: username, channel: channel } }

      it 'calls slack' do
        subject
        expect(a_request(:post, slack_hook_url).with(body: body.to_json)).to have_been_made
      end
    end
  end

  describe '#send_error' do
    subject { described_class.new(slack_hook_url).send_error(error, context, tags, additional_info) }

    let(:error) { double(:error, message: 'fake message', backtrace: ['foo'] * 15) }
    let(:context) { build(:request_context) }
    let(:tags) { %i[foo bar] }
    let(:additional_info) { 'foobar' }
    let(:message) { { text: expected_text } }
    let(:expected_text) do
      "[`#{server}`] [` #{Time.now.iso8601} `][` foo `][` bar `] *Ocorreu um erro!*\n" \
      "Contexto: `#{context.to_json}`\n" \
      "Mensagem: `fake message`\n" \
      "Stacktrace:\n```\nfoo\nfoo\nfoo\nfoo\nfoo\nfoo\nfoo\nfoo\nfoo\nfoo\n```\n" \
      'Informações adicionais: foobar'
    end

    before do
      Timecop.freeze(Time.utc(2017, 10, 10, 7, 20, 3))
    end

    it 'calls slack' do
      subject
      expect(a_request(:post, slack_hook_url).with(body: message.to_json)).to have_been_made
    end
  end
end
