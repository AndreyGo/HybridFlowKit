import UIKit

/// Factory helpers for producing configured navigation controllers used by flows.
public enum NavigationControllerProvider {
    /// Creates a fresh navigation controller instance.
    /// - Returns: A new `UINavigationController`.
    public static func makeNavigationController() -> UINavigationController {
        UINavigationController()
    }

    /// Wraps a view controller into a navigation controller instance.
    /// - Parameter viewController: The controller to become the root of the navigation stack.
    /// - Returns: Configured navigation controller with the provided root controller.
    public static func root(_ viewController: UIViewController) -> UINavigationController {
        UINavigationController(rootViewController: viewController)
    }
}
