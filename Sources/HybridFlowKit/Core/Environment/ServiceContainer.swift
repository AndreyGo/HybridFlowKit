import Foundation

/// Lightweight dependency injection container for registering and resolving services by type.
public final class ServiceContainer {
    private var services: [ObjectIdentifier: Any]
    private let queue = DispatchQueue(label: "com.hybridflowkit.servicecontainer", attributes: .concurrent)

    public init() {
        self.services = [:]
    }

    /// Registers a concrete instance for the given service type.
    /// - Parameters:
    ///   - type: Protocol or concrete type used as the lookup key.
    ///   - instance: Instance to store inside the container.
    public func register<Service>(_ type: Service.Type, instance: Service) {
        let identifier = ObjectIdentifier(type)
        queue.async(flags: .barrier) { [weak self] in
            self?.services[identifier] = instance
        }
    }

    /// Resolves the previously registered instance for the given type.
    /// - Parameter type: Protocol or concrete type used as the lookup key.
    /// - Returns: Stored instance cast to the requested type.
    public func resolve<Service>(_ type: Service.Type) -> Service {
        let identifier = ObjectIdentifier(type)
        return queue.sync {
            guard let service = services[identifier] as? Service else {
                assertionFailure("Service for type \(type) not registered")
                fatalError("Service for type \(type) not registered")
            }
            return service
        }
    }

    /// Resolves the previously registered instance for the given type if available.
    /// - Parameter type: Protocol or concrete type used as the lookup key.
    /// - Returns: Stored instance cast to the requested type, or `nil` if missing.
    public func resolveIfRegistered<Service>(_ type: Service.Type) -> Service? {
        let identifier = ObjectIdentifier(type)
        return queue.sync { services[identifier] as? Service }
    }
}
