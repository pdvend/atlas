# frozen_string_literal: true

RSpec.describe Atlas::Repository::RedisRepository, type: :repository do

  let(:redis_instance) { double(get: get_value, set: set_value) }
  let(:set_value) { 'OK' }

  describe '#cache' do
    subject { described_class.new(redis_instance).cache('nome', expiration: 10) { 'value' } }

    context 'when get is nil' do
      let(:get_value) { nil }

      it { is_expected.to eq('value')}
    end

    context 'when get has a value' do
      let(:get_value) { 'Otávio' }

      it { is_expected.to eq(get_value) }
    end
  end
end
