module Atlas
  Dependencies = Dry::Container.new.tap do |container|
    container.namespace(:service) do
      namespace(:telemetry) do
        register(:emit) { Atlas::Service::Telemetry::Emit.new }
      end
    end

    container.namespace(:vendor) do
      register(:kafka) do
        Kafka.new(
          seed_brokers: ENV['KAFKA_BROKERS'].split(','), client_id: ENV['KAFKA_CLIENT_ID']
        )
      end
    end
  end
end
