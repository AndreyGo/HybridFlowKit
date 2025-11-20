import UIKit
import HybridFlowKit

// Demonstrates a feature-specific navigator that coordinates module transitions.
protocol SettingsNavigator: Navigator {
    func showAccount()
    func showNotifications()
}

final class SettingsFlowCoordinator: FlowCoordinator, SettingsNavigator {
    override func start() {
        push(makeSettingsListModule(), animated: false)
    }

    func showAccount() {
        push(makeDetailModule(title: "Account"))
    }

    func showNotifications() {
        push(makeDetailModule(title: "Notifications"))
    }

    private func makeSettingsListModule() -> ScreenModule {
        let controller = SettingsListViewController(navigator: self)
        return ScreenModule(viewController: controller, retainCycle: controller)
    }

    private func makeDetailModule(title: String) -> ScreenModule {
        let controller = UIViewController()
        controller.view.backgroundColor = .systemBackground
        controller.title = title

        let label = makeLabel(text: title)
        controller.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
        ])

        return ScreenModule(viewController: controller)
    }

    private func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .title2)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        return label
    }
}

/// A simple screen that uses the navigator to route to additional settings screens.
final class SettingsListViewController: UITableViewController {
    private let navigator: SettingsNavigator
    private let items: [String] = ["Account", "Notifications"]

    init(navigator: SettingsNavigator) {
        self.navigator = navigator
        super.init(style: .insetGrouped)
        title = "Settings"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch items[indexPath.row] {
        case "Account":
            navigator.showAccount()
        case "Notifications":
            navigator.showNotifications()
        default:
            break
        }
    }
}

// MARK: - Using a ScreenFactory for a type-safe router

enum SettingsRoute {
    case list
    case account
    case notifications
}

struct SettingsFactory: ScreenFactory {
    func make(route: SettingsRoute) -> ScreenModule {
        switch route {
        case .list:
            let controller = UIViewController()
            controller.view.backgroundColor = .systemGroupedBackground
            controller.title = "Settings"
            return ScreenModule(viewController: controller)
        case .account:
            let controller = UIViewController()
            controller.view.backgroundColor = .systemGroupedBackground
            controller.title = "Account"
            return ScreenModule(viewController: controller)
        case .notifications:
            let controller = UIViewController()
            controller.view.backgroundColor = .systemGroupedBackground
            controller.title = "Notifications"
            return ScreenModule(viewController: controller)
        }
    }
}
