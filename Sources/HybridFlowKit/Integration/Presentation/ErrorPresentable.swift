import UIKit

/// Protocol for entities capable of presenting errors to the user.
public protocol ErrorPresentable {
    func showError(_ error: Error, on viewController: UIViewController?)
}

/// Default implementation that displays alerts using `UIAlertController`.
public final class DefaultErrorPresenter: ErrorPresentable {
    public init() {}

    public func showError(_ error: Error, on viewController: UIViewController?) {
        DispatchQueue.main.async {
            let presentingController = viewController ?? Self.topViewController()
            guard let host = presentingController else { return }

            let alert = UIAlertController(
                title: "Error",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            host.present(alert, animated: true, completion: nil)
        }
    }

    private static func topViewController(from controller: UIViewController? = nil) -> UIViewController? {
        let root = controller ?? UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController

        if let navigation = root as? UINavigationController {
            return topViewController(from: navigation.visibleViewController)
        }

        if let tab = root as? UITabBarController {
            return topViewController(from: tab.selectedViewController)
        }

        if let presented = root?.presentedViewController {
            return topViewController(from: presented)
        }

        return root
    }
}
