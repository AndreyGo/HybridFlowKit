import Foundation

/// Abstraction for logging within HybridFlowKit-powered applications.
public protocol LoggerProtocol {
    func log(_ message: String)
    func log(error: Error)
}

/// Default logger that proxies calls to the built-in `Logger` utility.
public struct DefaultLogger: LoggerProtocol {
    public init() {}

    public func log(_ message: String) {
        Logger.logFlowTransition(message)
    }

    public func log(error: Error) {
        Logger.logFlowTransition("Error: \(error.localizedDescription)")
    }
}
