RSpec.describe Atlas::Service::RequestContext, type: :entity do
  describe '.new' do
    subject { described_class.new(params) }
    let(:params) do
      {
        time: time,
        component: component,
        caller: _caller,
        transaction_id: transaction_id,
        account_id: account_id,
        authentication_type: authentication_type
      }
    end
    let(:time) { DateTime.now.utc.to_datetime }
    let(:component) { 'Test Component' }
    let(:_caller) { 'localhost' }
    let(:transaction_id) { SecureRandom.uuid }
    let(:account_id) { SecureRandom.uuid }
    let(:authentication_type) { :user }

    context 'with valid params' do
      it { expect { subject }.to_not raise_error }
      it { is_expected.to be_valid }
    end

    context 'with invalid params' do
      context 'invalid time' do
        let(:time) { 'invalid time' }
        it { expect { subject }.to_not raise_error }
        it { is_expected.to_not be_valid }
      end

      context 'invalid component' do
        let(:component) { 10_000 }
        it { expect { subject }.to_not raise_error }
        it { is_expected.to_not be_valid }
      end

      context 'invalid caller' do
        let(:_caller) { nil }
        it { expect { subject }.to_not raise_error }
        it { is_expected.to_not be_valid }
      end

      context 'invalid transaction id' do
        let(:transaction_id) { 'FAKE TRANSACTION ID' }
        it { expect { subject }.to_not raise_error }
        it { is_expected.to_not be_valid }
      end

      context 'invalid account id' do
        let(:account_id) { 'FAKE ACCOUNT ID' }
        it { expect { subject }.to_not raise_error }
        it { is_expected.to_not be_valid }
      end

      context 'invalid authentication type' do
        let(:authentication_type) { :invalid }
        it { expect { subject }.to_not raise_error }
        it { is_expected.to_not be_valid }
      end
    end
  end

  describe '#to_event' do
    subject { described_class.new(params).to_event }

    let(:params) do
      {
        time: DateTime.now.utc.to_datetime,
        component: 'Test Component',
        caller: 'localhost',
        transaction_id: SecureRandom.uuid,
        account_id: SecureRandom.uuid,
        authentication_type: :user
      }
    end

    before do
      Timecop.freeze(params[:time] + 1)
    end

    it { is_expected.to be_a(Hash) }
    it { expect(subject[:start_time]).to eq(params[:time].iso8601) }
    it do
      expect(subject[:elapsed_time]).to be_within(0.001).of(86_400)
    end
    it do
      expect(subject.keys).to match_array(%i[
        start_time
        elapsed_time
        component
        caller
        transaction_id
        account_id
        authentication_type
      ])
    end
  end

  describe '#user?' do
    subject { described_class.new(authentication_type: authentication_type).user? }

    context 'when authentication_type is :user' do
      let(:authentication_type) { :user }
      it { is_expected.to be_truthy }
    end

    context 'when authentication_type is not :user' do
      let(:authentication_type) { :unknown }
      it { is_expected.to be_falsey }
    end
  end

  describe '#system?' do
    subject { described_class.new(authentication_type: authentication_type).system? }

    context 'when authentication_type is :system' do
      let(:authentication_type) { :system }
      it { is_expected.to be_truthy }
    end

    context 'when authentication_type is not :system' do
      let(:authentication_type) { :unknown }
      it { is_expected.to be_falsey }
    end
  end

  describe '#authenticated?' do
    subject { described_class.new(authentication_type: authentication_type).authenticated? }

    context 'when authentication_type is :user' do
      let(:authentication_type) { :user }
      it { is_expected.to be_truthy }
    end

    context 'when authentication_type is :account' do
      let(:authentication_type) { :account }
      it { is_expected.to be_truthy }
    end

    context 'when authentication_type is :system' do
      let(:authentication_type) { :system }
      it { is_expected.to be_truthy }
    end

    context 'when authentication_type is :none' do
      let(:authentication_type) { :none }
      it { is_expected.to be_falsey }
    end

    context 'when authentication_type is unknown' do
      let(:authentication_type) { :unknown }
      it { is_expected.to be_falsey }
    end
  end

  describe '#unauthenticated?' do
    subject { described_class.new(authentication_type: authentication_type).unauthenticated? }

    context 'when authentication_type is :user' do
      let(:authentication_type) { :user }
      it { is_expected.to be_falsey }
    end

    context 'when authentication_type is :account' do
      let(:authentication_type) { :account }
      it { is_expected.to be_falsey }
    end

    context 'when authentication_type is :system' do
      let(:authentication_type) { :system }
      it { is_expected.to be_falsey }
    end

    context 'when authentication_type is :none' do
      let(:authentication_type) { :none }
      it { is_expected.to be_truthy }
    end

    context 'when authentication_type is unknown' do
      let(:authentication_type) { :unknown }
      it { is_expected.to be_truthy }
    end
  end
end
