RSpec.describe Atlas::Service::Util::SearchService, type: :service do
  describe '#format' do
    subject do
      klass = Class.new
      klass.include(described_class)
      klass.new.send(:format, params, &block)
    end

    let(:params) { {} }
    let(:block) { ->() {} }

    before do
      allow_any_instance_of(Atlas::Service::Mechanism::ServiceResponseFormatter)
        .to receive(:format)
        .and_return(format_response)
    end

    context 'when formatter returns success' do
      let(:format_response) { build(:repository_response, :success) }

      it_behaves_like 'a service with successful response'
      it { expect(subject.data).to eq(format_response.data) }
    end

    context 'when formatter returns failure' do
      let(:format_response) { build(:repository_response, :failure) }

      it_behaves_like 'a service with failure response'
    end
  end
end
