import UIKit

/// Coordinator for modal flows presented from within another flow.
open class ModalFlowCoordinator: Flow {
    public let rootViewController: UIViewController
    public var onFinish: ((FlowFinishEvent) -> Void)?

    /// Optional environment for logging and shared services.
    public let environment: AppEnvironment?

    private var retainedObjects: [AnyObject] = []

    /// Initializes a modal flow coordinator.
    /// - Parameters:
    ///   - rootViewController: The root controller for the modal flow. Defaults to a new `UINavigationController`.
    ///   - environment: Optional application environment.
    public init(
        rootViewController: UIViewController = UINavigationController(),
        environment: AppEnvironment? = nil
    ) {
        self.rootViewController = rootViewController
        self.environment = environment
    }

    /// Entry point for the modal flow. Override to perform initial setup or navigation.
    open func start() {
        logFlow("ModalFlowCoordinator started")
    }

    /// Finishes the modal flow with a specific event.
    /// - Parameter event: Completion event propagated to the parent flow.
    open func finish(_ event: FlowFinishEvent) {
        logFlow("ModalFlowCoordinator finished with event: \(event)")
        onFinish?(event)
    }

    /// Pushes a module if the root view controller is a `UINavigationController`.
    /// - Parameters:
    ///   - module: Module to push onto the navigation stack.
    ///   - animated: Animation flag for the transition.
    open func push(_ module: ScreenModule, animated: Bool = true) {
        guard let navigationController = rootViewController as? UINavigationController else {
            return
        }

        retain(module)
        logNavigation("push", viewController: module.viewController)
        navigationController.pushViewController(module.viewController, animated: animated)
    }

    /// Presents a module modally from the root view controller.
    /// - Parameters:
    ///   - module: Module to present.
    ///   - animated: Animation flag for the transition.
    open func present(_ module: ScreenModule, animated: Bool = true) {
        retain(module)
        logNavigation("present", viewController: module.viewController)
        rootViewController.present(module.viewController, animated: animated)
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
