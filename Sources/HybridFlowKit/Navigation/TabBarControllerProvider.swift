import UIKit

/// Factory helpers for creating tab bar controllers.
public enum TabBarControllerProvider {
    /// Creates a new tab bar controller instance.
    /// - Returns: A new `UITabBarController` ready for configuration.
    public static func makeTabBarController() -> UITabBarController {
        UITabBarController()
    }
}
