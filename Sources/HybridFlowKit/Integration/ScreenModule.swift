import UIKit

/// Wraps a view controller with an optional retained dependency (e.g., a view model).
public struct ScreenModule {
    public let viewController: UIViewController
    public let retainCycle: AnyObject?

    /// Creates a screen module.
    /// - Parameters:
    ///   - viewController: The view controller to display.
    ///   - retainCycle: Optional object retained alongside the view controller to keep related components alive.
    public init(viewController: UIViewController, retainCycle: AnyObject? = nil) {
        self.viewController = viewController
        self.retainCycle = retainCycle
    }
}
