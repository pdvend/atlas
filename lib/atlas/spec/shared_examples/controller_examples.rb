require 'rspec/core/shared_context'

module Atlas
  module Spec
    module SharedExamples
      module ControllerExamples
        extend RSpec::Core::SharedContext

        shared_examples_for('a controller that returns success') do
          it { expect(subject[0]).to be_between(200, 299).inclusive }
        end

        shared_examples_for('a controller that returns paginated response') do
          it_behaves_like 'a controller that returns success'
          it { expect(subject[1]).to include('Total') }
          it { expect(subject[1]).to include('Per-Page') }
        end

        shared_examples_for('a controller that returns failure') do
          it { expect(subject[0]).to be > 299 }
        end

        shared_examples_for('a controller that is unauthorized') do
          it { expect(subject[0]).to eq(403) }
        end
      end
    end
  end
end
