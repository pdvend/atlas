module Mock
  class Repository
    def initialize(responses)
      @responses = responses || {}
    end

    def method_missing(name, *)
      @responses[name] || super
    end

    def respond_to_missing?(name)
      @responses[name].present?
    end
  end
end
