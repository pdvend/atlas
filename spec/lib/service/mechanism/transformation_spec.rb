RSpec.describe Atlas::Service::Mechanism::Transformation do
  describe '.sorting_params' do
    subject { described_class.transformation_params(params, entity) }
    let(:entity) { Atlas::Spec::Mock::Entity[:value] }

    context 'with nil params' do
      let(:params) { nil }
      it { is_expected.not_to be_success }
      it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::PARAMETER_ERROR) }
      it { expect(subject.message).to eq('Invalid parameters received to execute this action') }
    end

    context 'with invalid params' do
      let(:params) { Object.new }
      it { is_expected.not_to be_success }
      it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::PARAMETER_ERROR) }
      it { expect(subject.message).to eq('Invalid parameters received to execute this action') }
    end

    context 'with valid field but operation does not exist' do
      let(:params) { 'invalid_operation:value' }
      it { is_expected.not_to be_success }
      it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::PARAMETER_ERROR) }
      it { expect(subject.message).to eq('Invalid operation') }
    end

    context 'with valid operation but field does not exist' do
      let(:params) { 'sum:invalid_field' }
      it { is_expected.not_to be_success }
      it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::PARAMETER_ERROR) }
      it { expect(subject.message).to eq('Invalid field') }
    end

    context 'when valid' do
      context 'when sum' do
        let(:params) { 'sum:value' }
        it { is_expected.to be_success }
        it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::NONE) }
        it { expect(subject.data).to eq(operation: :sum, field: :value) }
      end

      context 'when count' do
        context 'when field is present' do
          let(:params) { 'count:value' }
          it { is_expected.to be_success }
          it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::NONE) }
          it { expect(subject.data).to eq(operation: :count) }
        end

        context 'when field not is present' do
          let(:params) { 'count' }
          it { is_expected.to be_success }
          it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::NONE) }
          it { expect(subject.data).to eq(operation: :count) }
        end
      end
    end
  end
end
