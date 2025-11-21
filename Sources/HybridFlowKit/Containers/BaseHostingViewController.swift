#if canImport(SwiftUI)
import SwiftUI
import UIKit

/// Hosts a SwiftUI view inside a UIKit view controller while keeping proper child controller semantics.
open class BaseHostingViewController<Content: View>: UIViewController {
    /// The SwiftUI view to be rendered.
    public let rootView: Content

    private var hostingController: UIHostingController<Content>?

    /// Initializes a hosting view controller with the provided SwiftUI content.
    /// - Parameter rootView: The SwiftUI view to embed.
    public init(rootView: Content) {
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        nil
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        embedHostingController()
    }

    open override var childForStatusBarStyle: UIViewController? {
        hostingController
    }

    open override var childForStatusBarHidden: UIViewController? {
        hostingController
    }

    private func embedHostingController() {
        let hostingController = UIHostingController(rootView: rootView)
        self.hostingController = hostingController

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)

        Logger.logNavigation("embedding SwiftUI", viewController: hostingController)
    }
}
#endif
