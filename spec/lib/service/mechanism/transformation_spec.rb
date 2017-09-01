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

    context 'with valid field but operator does not exist' do
      let(:params) { 'invalid_operator:value' }
      it { is_expected.not_to be_success }
      it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::PARAMETER_ERROR) }
      it { expect(subject.message).to eq('Invalid operator') }
    end

    context 'with valid operator but field does not exist' do
      let(:params) { 'sum:invalid_field' }
      it { is_expected.not_to be_success }
      it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::PARAMETER_ERROR) }
      it { expect(subject.message).to eq('Invalid field') }
    end

    context 'when valid' do
      let(:params) { 'sum:value' }
      it { is_expected.to be_success }
      it { expect(subject.code).to eq(Atlas::Enum::ErrorCodes::NONE) }
      it { expect(subject.data).to eq(operator: 'sum', field: 'value') }
    end
  end
end
