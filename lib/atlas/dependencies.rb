module Atlas
  Dependencies = Dry::Container.new.tap do |container|
    container.namespace(:service) do
      namespace(:telemetry) do
        register(:emit) { Atlas::Service::Telemetry::Emit.new }
      end
    end
  end
end
