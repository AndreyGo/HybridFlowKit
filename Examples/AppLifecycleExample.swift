import UIKit
import HybridFlowKit

// Demonstrates how to drive multiple flows using `AppStateController`.
final class ApplicationController: AppStateController {
    override func makeFlow(for state: AppState) -> Flow {
        switch state {
        case .onboarding:
            return OnboardingFlowCoordinator()
        case .authorized:
            return MainFlowCoordinator()
        case .guest:
            return GuestFlowCoordinator()
        default:
            return super.makeFlow(for: state)
        }
    }
}

// A simple onboarding flow that finishes by switching the app into an authorized state.
final class OnboardingFlowCoordinator: FlowCoordinator {
    override func start() {
        push(makeWelcomeModule(), animated: false)
    }

    private func makeWelcomeModule() -> ScreenModule {
        let controller = ActionViewController(title: "Welcome to HybridFlowKit", buttonTitle: "Continue")
        controller.onTap = { [weak self] in
            self?.finish(.switchToAuthorized)
        }
        return ScreenModule(viewController: controller, retainCycle: controller)
    }
}

// The main flow shows the primary interface and allows users to log out.
final class MainFlowCoordinator: FlowCoordinator {
    override func start() {
        push(makeDashboardModule(), animated: false)
    }

    private func makeDashboardModule() -> ScreenModule {
        let controller = ActionViewController(title: "Dashboard", buttonTitle: "Log out")
        controller.onTap = { [weak self] in
            self?.finish(.logout)
        }
        return ScreenModule(viewController: controller, retainCycle: controller)
    }
}

// A guest experience that can ask the user to register and continue to onboarding.
final class GuestFlowCoordinator: FlowCoordinator {
    override func start() {
        push(makeGuestModule(), animated: false)
    }

    private func makeGuestModule() -> ScreenModule {
        let controller = ActionViewController(title: "Guest", buttonTitle: "Register")
        controller.onTap = { [weak self] in
            self?.finish(.switchToOnboarding)
        }
        return ScreenModule(viewController: controller, retainCycle: controller)
    }
}

// MARK: - Simple button-driven controller used by the flows above.

final class ActionViewController: UIViewController {
    var onTap: (() -> Void)?

    private let titleLabel = UILabel()
    private let button = UIButton(type: .system)

    init(title: String, buttonTitle: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        titleLabel.text = title
        button.setTitle(buttonTitle, for: .normal)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let stackView = UIStackView(arrangedSubviews: [titleLabel, button])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }

    @objc private func didTapButton() {
        onTap?()
    }
}

// MARK: - Wiring everything together

func startHybridFlow(in window: UIWindow) {
    let controller = ApplicationController(initialState: .onboarding)

    controller.onFlowFinish = { event in
        if event == .logout {
            controller.setState(.guest)
        }
    }

    window.rootViewController = controller.currentRootViewController()
    controller.currentFlow?.start()
}
