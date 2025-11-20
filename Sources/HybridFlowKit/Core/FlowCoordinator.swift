import UIKit

/// Base implementation of `Flow` built around a `UINavigationController`.
open class FlowCoordinator: Flow {
    /// Navigation controller used to drive the flow.
    public let navigationController: UINavigationController

    /// Callback invoked when the flow finishes.
    public var onFinish: ((FlowFinishEvent) -> Void)?

    /// Retained helper objects such as view models to keep them alive for presented modules.
    private var retainedObjects: [AnyObject] = []

    /// Creates a new coordinator instance with the provided navigation controller.
    /// - Parameter navigationController: Custom navigation controller instance. Defaults to a new controller.
    public init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }

    /// Exposes the navigation controller as the flow's root view controller.
    open var rootViewController: UIViewController { navigationController }

    /// Starts the flow. Subclasses should override to perform the first navigation action.
    open func start() {
        Logger.logFlowTransition("FlowCoordinator started")
    }

    /// Pushes a screen module on the navigation stack.
    /// - Parameters:
    ///   - module: The module to push.
    ///   - animated: Pass `true` to animate the transition.
    open func push(_ module: ScreenModule, animated: Bool = true) {
        retain(module)
        Logger.logNavigation("push", viewController: module.viewController)
        navigationController.pushViewController(module.viewController, animated: animated)
    }

    /// Presents a screen module modally from the navigation controller.
    /// - Parameters:
    ///   - module: The module to present.
    ///   - animated: Pass `true` to animate the transition.
    open func present(_ module: ScreenModule, animated: Bool = true) {
        retain(module)
        Logger.logNavigation("present", viewController: module.viewController)
        navigationController.present(module.viewController, animated: animated)
    }

    /// Pops the top view controller from the navigation stack.
    /// - Parameter animated: Pass `true` to animate the transition.
    open func pop(animated: Bool = true) {
        Logger.logNavigation("pop", viewController: navigationController.topViewController)
        navigationController.popViewController(animated: animated)
    }

    /// Finishes the coordinator and notifies listeners with the provided event.
    /// - Parameter event: The finish event.
    open func finish(_ event: FlowFinishEvent) {
        Logger.logFlowTransition("FlowCoordinator finished with event: \(event)")
        onFinish?(event)
    }

    private func retain(_ module: ScreenModule) {
        if let retainCycle = module.retainCycle {
            retainedObjects.append(retainCycle)
        }
    }
}
