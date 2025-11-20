import UIKit

/// Simple logger for debugging navigation actions and flow transitions.
public enum Logger {
    /// Indicates whether logging is enabled.
    public static var isEnabled = false

    /// Logs a flow transition message.
    /// - Parameter message: Description of the transition.
    public static func logFlowTransition(_ message: String) {
        guard isEnabled else { return }
        print("[HybridFlowKit][Flow] \(message)")
    }

    /// Logs navigation changes in the view hierarchy.
    /// - Parameters:
    ///   - action: A human-readable description of the navigation action.
    ///   - viewController: Optional view controller involved in the action.
    public static func logNavigation(_ action: String, viewController: UIViewController?) {
        guard isEnabled else { return }
        let description = viewController.map { String(describing: type(of: $0)) } ?? "none"
        print("[HybridFlowKit][Navigation] \(action) -> \(description)")
    }
}
