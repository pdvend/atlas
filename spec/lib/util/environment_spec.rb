# frozen_string_literal: true

RSpec.describe Atlas::Util::Environment, type: :module do
  context 'when test' do
    it { expect(subject.test?).to eq(true) }
    it { expect(subject.production?).to eq(false) }
    it { expect(subject.development?).to eq(false) }
  end
end
