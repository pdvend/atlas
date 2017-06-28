RSpec.describe Atlas::Repository::BaseS3Repository, type: :repository do
  before do
    allow_any_instance_of(described_class).to receive(:bucket_name).and_return('foobar')
  end

  describe '#put' do
    subject { described_class.new.put(uuid, content) }

    let(:uuid) { SecureRandom.uuid }
    let(:content) { SecureRandom.base64(20) }

    context 'when uuid is invalid' do
      let(:uuid) { nil }

      it { expect { subject }.to_not raise_error }
      it { is_expected.to_not be_success }
      it { expect(subject.data).to be_nil }
    end

    context 'when content is invalid' do
      let(:uuid) { nil }

      it { expect { subject }.to_not raise_error }
      it { is_expected.to_not be_success }
      it { expect(subject.data).to be_nil }
    end

    context 'when params are valid' do
      let(:mock_s3_resource) { double('Aws::S3::Resource') }
      let(:mock_s3_bucket) { double('Aws::S3::Bucket') }
      let(:mock_s3_object) { double('Aws::S3::Object') }

      before do
        expect(mock_s3_bucket).to receive(:object).and_return(mock_s3_object)
        expect(mock_s3_resource).to receive(:bucket).and_return(mock_s3_bucket)
        expect(Aws::S3::Resource).to receive(:new).and_return(mock_s3_resource)
      end

      context 'when upload fails' do
        before do
          expect(mock_s3_object).to receive(:upload_file).and_raise(Aws::S3::Errors::ServiceError.new('foo', 'bar'))
        end

        it { expect { subject }.to_not raise_error }
        it { is_expected.to_not be_success }
        it { expect(subject.data).to be_nil }
      end

      context 'when upload success' do
        before do
          expect(mock_s3_object).to receive(:upload_file).and_return(true)
        end

        it { expect { subject }.to_not raise_error }
        it { is_expected.to be_success }
        it { expect(subject.data).to be_nil }
      end
    end
  end

  describe '#get' do
    subject { described_class.new.get(uuid, content) }

    let(:uuid) { SecureRandom.uuid }
    let(:content) { false }

    context 'when uuid is invalid' do
      let(:uuid) { nil }

      it { expect { subject }.to_not raise_error }
      it { is_expected.to_not be_success }
      it { expect(subject.data).to be_nil }
    end

    context 'when params are valid' do
      let(:mock_s3_resource) { double('Aws::S3::Resource') }
      let(:mock_s3_bucket) { double('Aws::S3::Bucket') }
      let(:mock_s3_object) { double('Aws::S3::Object') }

      before do
        expect(mock_s3_bucket).to receive(:object).and_return(mock_s3_object)
        expect(mock_s3_resource).to receive(:bucket).and_return(mock_s3_bucket)
        expect(Aws::S3::Resource).to receive(:new).and_return(mock_s3_resource)
      end

      context 'when download fails' do
        before do
          expect(mock_s3_object).to receive(:get).and_raise(Aws::S3::Errors::ServiceError.new('foo', 'bar'))
        end

        it { expect { subject }.to_not raise_error }
        it { is_expected.to_not be_success }
        it { expect(subject.data).to be_nil }
      end

      context 'when download succeeds' do
        before do
          expect(mock_s3_object).to receive(:get) do |params|
            File.binwrite(params[:response_target], SecureRandom.base64)
          end
        end

        it { expect { subject }.to_not raise_error }
        it { is_expected.to be_success }
        it { expect(subject.data).to_not be_nil }

        context 'when content is true' do
          let(:content) { true }
          it { expect(subject.data).to be_a(String) }
        end

        context 'when content is false' do
          let(:content) { false }
          it { expect(subject.data).to be_a(File) }
        end
      end
    end
  end
end
