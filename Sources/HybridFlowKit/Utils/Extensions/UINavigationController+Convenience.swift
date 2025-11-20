import UIKit

public extension UINavigationController {
    /// Pushes a screen module while retaining its associated object if available.
    /// - Parameters:
    ///   - module: The module to push.
    ///   - animated: Indicates whether the push should be animated.
    func hfk_pushModule(_ module: ScreenModule, animated: Bool = true) {
        Logger.logNavigation("push", viewController: module.viewController)
        pushViewController(module.viewController, animated: animated)
    }

    /// Presents a screen module modally.
    /// - Parameters:
    ///   - module: The module to present.
    ///   - animated: Indicates whether the presentation should be animated.
    func hfk_presentModule(_ module: ScreenModule, animated: Bool = true) {
        Logger.logNavigation("present", viewController: module.viewController)
        present(module.viewController, animated: animated)
    }
}
