# frozen_string_literal: true

RSpec.describe Atlas::Job::Processor, type: :service do
  let(:backend) { double(:backend) }
  let(:notifier) { double(:notifier) }
  let(:jobs) { [job_class] }
  let(:job_class) { double(:job_class, topic: job_topic, timeout_delay: job_timeout, retries: job_retries) }
  let(:job) { double(:job, class: job_class, perform: job_result) }
  let(:job_topic) { 'foo' }
  let(:job_timeout) { 3600 }
  let(:job_retries) { 5 }
  let(:job_result) { Atlas::Enum::JobsResponseCodes::PROCESS_MESSAGE }

  before do
    allow(job_class).to receive(:new).and_return(job)
    allow(backend).to receive(:listen)
  end

  describe '.new' do
    subject { described_class.new(backend: backend, notifier: notifier, jobs: jobs) }

    it { expect { subject }.to_not raise_error }
  end

  describe '#process' do
    subject { described_class.new(backend: backend, notifier: notifier, jobs: jobs).process }

    before do
      allow(backend).to receive(:listen)
      allow(backend).to receive(:consume)
    end

    it 'asks backend to listen to topic' do
      expect(backend).to receive(:listen).with(job_topic)
      subject
    end

    it 'consumes messages from backend' do
      expect(backend).to receive(:consume)
      subject
    end

    context 'when backend returns a message' do
      let(:message) { build(:job_message, topic: topic, timestamp: timestamp, retries: retries) }

      before do
        allow(backend).to receive(:consume).and_yield(message)
        allow(backend).to receive(:mark_message_as_processed)
      end

      let(:topic) { job_topic }
      let(:timestamp) { 0 }
      let(:retries) { 0 }

      context 'when message topic is not registered' do
        let(:topic) { job_topic.succ }

        before do
          allow(notifier).to receive(:send_message)
        end

        it 'notifies' do
          expect(notifier).to receive(:send_message)
          subject
        end

        it 'does not execute job' do
          expect(job).to_not receive(:perform)
          subject
        end
      end

      context 'when job is in delay phase' do
        let(:timestamp) { (job_timeout - 1).seconds.from_now.to_i }

        it 'does not execute job' do
          expect(job).to_not receive(:perform)
          subject
        end
      end

      context 'when job processing raises exception' do
        before do
          allow(job).to receive(:perform).and_raise
          allow(notifier).to receive(:send_error)
          allow(backend).to receive(:produce)
        end

        it 'notifies about the error' do
          expect(notifier).to receive(:send_error)
          subject
        end

        context 'when message retries is smaller than job retries' do
          let(:retries) { job_retries - 1 }

          it 're-enqueue message' do
            expect(backend).to receive(:produce)
            subject
          end
        end

        context 'when message retries is equal to job retries' do
          let(:retries) { job_retries }

          it "won't re-enqueue message" do
            expect(backend).to_not receive(:produce)
            subject
          end
        end
      end

      context 'when job processing returns failure' do
        let(:job_result) { false }

        before do
          allow(notifier).to receive(:send_message)
          allow(backend).to receive(:produce)
        end

        it 'marks message as processed' do
          expect(backend).to receive(:mark_message_as_processed)
          subject
        end

        it 'notifies about the non processing state' do
          expect(notifier).to receive(:send_message)
          subject
        end

        context 'when message retries is smaller than job retries' do
          let(:retries) { job_retries - 1 }

          context 'when job returns common failure' do
            it 're-enqueue message' do
              expect(backend).to receive(:produce)
              subject
            end
          end

          context 'when job returns no retry failure' do
            let(:job_result) { Atlas::Enum::JobsResponseCodes::FAILED_NO_RETRY }

            it "won't re-enqueue message" do
              expect(backend).to_not receive(:produce)
              subject
            end
          end
        end

        context 'when message retries is equal to job retries' do
          let(:retries) { job_retries }

          it "won't re-enqueue message" do
            expect(backend).to_not receive(:produce)
            subject
          end
        end
      end

      context 'when the message is processed successfully' do
        it 'marks message as processed' do
          expect(backend).to receive(:mark_message_as_processed)
          subject
        end
      end
    end
  end

  describe '#enqueue' do
    subject do
      described_class
        .new(backend: backend, notifier: notifier, jobs: jobs)
        .enqueue(job_class, payload: payload)
    end

    let(:payload) { { foo: :bar } }

    it 'calls backend produce with default params' do
      expect(backend).to receive(:produce).with(job_topic, payload: payload, timestamp: 0, retries: 0)
      subject
    end
  end
end
