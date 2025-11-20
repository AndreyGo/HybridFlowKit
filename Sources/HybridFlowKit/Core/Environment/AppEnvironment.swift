import Foundation

/// Aggregates shared services and execution contexts used across flows.
public struct AppEnvironment {
    public let services: ServiceContainer
    public let logger: LoggerProtocol
    public let mainQueue: DispatchQueue
    public let backgroundQueue: DispatchQueue

    public init(
        services: ServiceContainer = ServiceContainer(),
        logger: LoggerProtocol = DefaultLogger(),
        mainQueue: DispatchQueue = .main,
        backgroundQueue: DispatchQueue = .global(qos: .userInitiated)
    ) {
        self.services = services
        self.logger = logger
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
    }
}
