import UIKit
import HybridFlowKit

final class PaywallFlow: ModalFlowCoordinator {
    override func start() {
        let controller = UIViewController()
        controller.view.backgroundColor = .systemBackground
        controller.title = "Paywall"

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.addAction(UIAction { [weak self] _ in
            self?.finish(.completed)
        }, for: .touchUpInside)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        controller.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
        ])

        if let navigationController = rootViewController as? UINavigationController {
            navigationController.viewControllers = [controller]
        }
    }
}

final class HomeFlow: FlowCoordinator {
    override func start() {
        let controller = UIViewController()
        controller.view.backgroundColor = .systemBackground
        controller.title = "Home"

        let showPaywallButton = UIButton(type: .system)
        showPaywallButton.setTitle("Show Paywall", for: .normal)
        showPaywallButton.addAction(UIAction { [weak self] _ in
            self?.presentPaywall()
        }, for: .touchUpInside)

        showPaywallButton.translatesAutoresizingMaskIntoConstraints = false
        controller.view.addSubview(showPaywallButton)
        NSLayoutConstraint.activate([
            showPaywallButton.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            showPaywallButton.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
        ])

        push(ScreenModule(viewController: controller), animated: false)
    }

    private func presentPaywall() {
        let paywallFlow = PaywallFlow(environment: environment)
        paywallFlow.onFinish = { [weak self] event in
            self?.environment?.logger.log("Paywall finished: \(event)")
            self?.navigationController.dismiss(animated: true, completion: nil)
        }
        paywallFlow.start()
        navigationController.present(paywallFlow.rootViewController, animated: true)
    }
}

func buildModalFlowExample() -> UIViewController {
    let environment = AppEnvironment()
    let homeFlow = HomeFlow(environment: environment)
    homeFlow.start()
    return homeFlow.rootViewController
}
