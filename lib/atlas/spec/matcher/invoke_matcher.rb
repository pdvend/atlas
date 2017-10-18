# frozen_string_literal: true

#-------------------------------+
# TODO: This can be another gem |
#-------------------------------+
#
# Adapted from: https://github.com/rspec/rspec-expectations/issues/934
#
# expect{ foo }.to invoke(Class, :method).and_call_original
#
# expect{ foo }.to change{ bar }.and not_invoke(Class, :method)
#
# expect{ foo }.to invoke(Class, :method).at_least(3).times
#
class InvokeMatcher
  def initialize(expected_recipient, expected_method)
    @expected_recipient = expected_recipient
    @expected_method = expected_method
    @have_received_matcher = RSpec::Mocks::Matchers::HaveReceived.new(@expected_method)
  end

  def description
    "invoke #{@expected_method} on #{@expected_recipient.inspect}"
  end

  def method_missing(name, *args, &block)
    super unless respond_to_missing?(name)
    @have_received_matcher = @have_received_matcher.public_send(name, *args, &block)
    self
  end

  # :reek:ManualDispatch
  def respond_to_missing?(name, *args)
    @have_received_matcher.respond_to?(name, *args)
  end

  def matches?(event_proc)
    unless @expected_recipient.is_a?(RSpec::Mocks::Double)
      allow(@expected_recipient).to receive(@expected_method).and_call_original
    end

    event_proc.call

    @have_received_matcher.matches?(@expected_recipient)
  end

  def failure_message
    @have_received_matcher.failure_message
  end

  def failure_message_when_negated
    @have_received_matcher.failure_message_when_negated
  end

  def supports_block_expectations?
    true
  end

  private

  def allow(_target)
    RSpec::Mocks::AllowanceTarget.new(@expected_recipient)
  end

  def receive(method_name)
    RSpec::Mocks::Matchers::Receive.new(method_name, nil)
  end
end

# :reek:UtilityFunction
def invoke(expected_recipient, expected_method)
  InvokeMatcher.new(expected_recipient, expected_method)
end

RSpec::Matchers.define_negated_matcher :not_invoke, :invoke
