import UIKit

/// Base implementation of `Flow` built around a `UINavigationController`.
open class FlowCoordinator: Flow {
    /// Navigation controller used to drive the flow.
    public let navigationController: UINavigationController

    /// Callback invoked when the flow finishes.
    public var onFinish: ((FlowFinishEvent) -> Void)?

    /// Optional environment for logging and service access.
    public let environment: AppEnvironment?

    /// Retained helper objects such as view models to keep them alive for presented modules.
    private var retainedObjects: [AnyObject] = []

    /// Creates a new coordinator instance with the provided navigation controller.
    /// - Parameter navigationController: Custom navigation controller instance. Defaults to a new controller.
    /// - Parameter environment: Optional environment propagated across flows.
    public init(
        navigationController: UINavigationController = UINavigationController(),
        environment: AppEnvironment? = nil
    ) {
        self.navigationController = navigationController
        self.environment = environment
    }

    /// Exposes the navigation controller as the flow's root view controller.
    open var rootViewController: UIViewController { navigationController }

    /// Starts the flow. Subclasses should override to perform the first navigation action.
    open func start() {
        logFlow("FlowCoordinator started")
    }

    /// Pushes a screen module on the navigation stack.
    /// - Parameters:
    ///   - module: The module to push.
    ///   - animated: Pass `true` to animate the transition.
    open func push(_ module: ScreenModule, animated: Bool = true) {
        retain(module)
        logNavigation("push", viewController: module.viewController)
        navigationController.pushViewController(module.viewController, animated: animated)
    }

    /// Presents a screen module modally from the navigation controller.
    /// - Parameters:
    ///   - module: The module to present.
    ///   - animated: Pass `true` to animate the transition.
    open func present(_ module: ScreenModule, animated: Bool = true) {
        retain(module)
        logNavigation("present", viewController: module.viewController)
        navigationController.present(module.viewController, animated: animated)
    }

    /// Pops the top view controller from the navigation stack.
    /// - Parameter animated: Pass `true` to animate the transition.
    open func pop(animated: Bool = true) {
        logNavigation("pop", viewController: navigationController.topViewController)
        navigationController.popViewController(animated: animated)
    }

    /// Finishes the coordinator and notifies listeners with the provided event.
    /// - Parameter event: The finish event.
    open func finish(_ event: FlowFinishEvent) {
        logFlow("FlowCoordinator finished with event: \(event)")
        onFinish?(event)
    }

    private func retain(_ module: ScreenModule) {
        if let retainCycle = module.retainCycle {
            retainedObjects.append(retainCycle)
        }
    }

    private func logFlow(_ message: String) {
        if let logger = environment?.logger {
            logger.log(message)
        } else {
            Logger.logFlowTransition(message)
        }
    }

    private func logNavigation(_ action: String, viewController: UIViewController?) {
        if let logger = environment?.logger {
            let description = viewController.map { String(describing: type(of: $0)) } ?? "none"
            logger.log("[Navigation] \(action) -> \(description)")
        } else {
            Logger.logNavigation(action, viewController: viewController)
        }
    }
}
