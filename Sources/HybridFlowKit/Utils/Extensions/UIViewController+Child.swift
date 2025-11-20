import UIKit

public extension UIViewController {
    /// Adds the provided view controller as a child with standard containment calls.
    /// - Parameter child: The child view controller to embed.
    func hfk_addChild(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    /// Adds the provided view controller as a child and pins its view to the edges.
    /// - Parameter child: The child view controller to embed and constrain.
    func hfk_pinChild(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        child.didMove(toParent: self)
    }
}
