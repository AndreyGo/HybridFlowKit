import UIKit

/// Describes a navigation flow that can manage a root view controller and notify about its completion.
public protocol Flow: AnyObject {
    /// The entry point view controller for the flow.
    var rootViewController: UIViewController { get }

    /// Callback invoked when the flow finishes with a specific event.
    var onFinish: ((FlowFinishEvent) -> Void)? { get set }

    /// Starts the flow and performs its initial navigation actions.
    func start()
}
