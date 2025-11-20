import UIKit

/// Provides references to common navigation controllers available in the hosting application.
public struct NavigationContext {
    public weak var navigationController: UINavigationController?
    public weak var tabBarController: UITabBarController?
    public weak var presentingViewController: UIViewController?

    /// Creates a new context with optional navigation primitives.
    /// - Parameters:
    ///   - navigationController: The active navigation controller if any.
    ///   - tabBarController: The active tab bar controller if any.
    ///   - presentingViewController: The controller currently presenting this module.
    public init(
        navigationController: UINavigationController? = nil,
        tabBarController: UITabBarController? = nil,
        presentingViewController: UIViewController? = nil
    ) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
        self.presentingViewController = presentingViewController
    }
}
