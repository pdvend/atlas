require 'rspec/core/shared_context'

module Atlas
  module Spec
    module SharedExamples
      module RouterExamples
        extend RSpec::Core::SharedContext

        shared_examples_for('a routable endpoint') do |method_type, path, params = {}|
          subject { described_class.recognize(env) }
          let(:env) { Rack::MockRequest.env_for(path, method: method_type) }

          it { expect(subject).to be_routable }
          it { expect(subject.path).to eq(path) }
          it { expect(subject.verb).to eq(method_type) }
          it { expect(subject.params).to eq(params) }
        end

        shared_examples_for('a not routable endpoint') do |method_type, path, params = {}|
          subject { described_class.recognize(env) }
          let(:env) { Rack::MockRequest.env_for(path, method: method_type) }

          it { expect(subject).to_not be_routable }
        end
      end
    end
  end
end
