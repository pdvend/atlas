# frozen_string_literal: true

RSpec.describe Atlas::Job::JobMessage, type: :entity do
  describe '.new' do
    subject { described_class.new(params) }
    let(:params) do
      {
        topic: topic,
        payload: payload,
        retries: retries,
        timestamp: timestamp,
        vendor_message: vendor_message
      }
    end

    let(:topic) { 'foo' }
    let(:payload) { { foo: :bar } }
    let(:retries) { 0 }
    let(:timestamp) { 0 }
    let(:vendor_message) { { bar: :baz } }

    context 'with valid params' do
      it { expect { subject }.to_not raise_error }
      it { is_expected.to be_valid }
    end

    context 'with invalid params' do
      context 'invalid topic' do
        let(:topic) { 123 }
        it { expect { subject }.to_not raise_error }
        it { is_expected.to_not be_valid }
      end

      context 'invalid payload' do
        let(:payload) { 10_000 }
        it { expect { subject }.to_not raise_error }
        it { is_expected.to_not be_valid }
      end

      context 'invalid retries' do
        context 'in type' do
          let(:retries) { nil }
          it { expect { subject }.to_not raise_error }
          it { is_expected.to_not be_valid }
        end

        context 'in value' do
          let(:retries) { -1 }
          it { expect { subject }.to_not raise_error }
          it { is_expected.to_not be_valid }
        end
      end

      context 'invalid timestamp' do
        context 'in type' do
          let(:timestamp) { nil }
          it { expect { subject }.to_not raise_error }
          it { is_expected.to_not be_valid }
        end

        context 'in value' do
          let(:timestamp) { -1 }
          it { expect { subject }.to_not raise_error }
          it { is_expected.to_not be_valid }
        end
      end
    end
  end

  describe '#to_hash' do
    subject { build(:job_message).to_hash }

    it "won't include vendor_message" do
      is_expected.to_not have_key(:vendor_message)
    end
  end
end
