import UIKit

/// Protocol for showing and hiding loading indicators.
public protocol LoadingPresentable {
    func showLoading(on viewController: UIViewController?)
    func hideLoading(from viewController: UIViewController?)
}

/// Default implementation that displays an overlay with a spinner.
public final class DefaultLoadingPresenter: LoadingPresentable {
    private static var overlays: [ObjectIdentifier: UIView] = [:]
    private static let lock = NSLock()

    public init() {}

    public func showLoading(on viewController: UIViewController?) {
        DispatchQueue.main.async {
            guard let host = viewController ?? Self.topViewController(), let hostView = host.view else { return }
            let key = ObjectIdentifier(host)

            Self.lock.lock()
            if Self.overlays[key] != nil {
                Self.lock.unlock()
                return
            }

            let overlay = UIView(frame: hostView.bounds)
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.25)

            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.startAnimating()
            overlay.addSubview(indicator)

            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
            ])

            hostView.addSubview(overlay)
            Self.overlays[key] = overlay
            Self.lock.unlock()
        }
    }

    public func hideLoading(from viewController: UIViewController?) {
        DispatchQueue.main.async {
            guard let host = viewController ?? Self.topViewController() else { return }
            let key = ObjectIdentifier(host)

            Self.lock.lock()
            let overlay = Self.overlays.removeValue(forKey: key)
            Self.lock.unlock()
            overlay?.removeFromSuperview()
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
