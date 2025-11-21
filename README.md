# HybridFlowKit

HybridFlowKit is a lightweight architectural toolkit for building hybrid iOS applications that mix UIKit and SwiftUI. It provides a common Flow/Coordinator mechanism, navigation helpers, UIKit containers for hosting SwiftUI, and utilities to rapidly assemble screen modules without coupling to business logic.

## Features
- Flow protocol with base coordinator and finish events.
- App state controller to swap flows for onboarding, authorization, splash, and more.
- Application environment with a lightweight service container and logger abstraction.
- Navigation helpers and context abstractions for UIKit-based routing.
- UIKit containers that host SwiftUI and support a collapsing header pattern.
- Screen module abstraction and factory protocol for type-safe module creation.
- Minimal logger and convenience extensions to streamline integration.
- Modal flow coordinator for presented experiences like paywalls or settings.
- Building blocks for paginated lists plus reusable loading/error presenters.

## Repository Structure
```
HybridFlowKit/
├── Package.swift
└── Sources/
    └── HybridFlowKit/
        ├── Core/
        ├── Navigation/
        ├── Containers/
        ├── Integration/
        └── Utils/
```

## Installation
Add the package URL to your project using Swift Package Manager and reference the `HybridFlowKit` product.

## Quick Start

### Switching flows with `AppStateController`
```swift
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

let appController = ApplicationController()
appController.onFlowFinish = { event in
    if event == .logout { appController.setState(.guest) }
}
window.rootViewController = appController.currentRootViewController()
appController.currentFlow?.start()
```

### Environment & Services
Use `AppEnvironment` to bundle services, loggers, and dispatch queues, then pass it through your flows.

```swift
protocol AuthService { func isAuthorized() -> Bool }

let services = ServiceContainer()
services.register(AuthService.self, instance: MyAuthService())

let environment = AppEnvironment(services: services, logger: DefaultLogger())
let appController = AppStateController(initialState: .authorized, environment: environment)
```

See `Examples/EnvironmentExample.swift` for a full example with a custom flow.

### Building flows with `FlowCoordinator`
```swift
final class OnboardingFlowCoordinator: FlowCoordinator {
    override func start() {
        let module = makeWelcomeModule()
        push(module)
    }

    private func makeWelcomeModule() -> ScreenModule {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBackground
        viewController.title = "Welcome"
        return ScreenModule(viewController: viewController)
    }
}
```

### Modal Flow
Use `ModalFlowCoordinator` to manage flows that are presented modally from another coordinator.

```swift
final class PaywallFlow: ModalFlowCoordinator {
    override func start() {
        let viewController = PaywallViewController()
        if let navigationController = rootViewController as? UINavigationController {
            navigationController.viewControllers = [viewController]
        }
    }
}

let paywallFlow = PaywallFlow(environment: environment)
paywallFlow.onFinish = { event in
    environment.logger.log("Paywall finished: \(event)")
}
paywallFlow.start()
navigationController.present(paywallFlow.rootViewController, animated: true)
```

See `Examples/ModalFlowExample.swift` for a complete demonstration.

### Creating a navigator inside a feature module
```swift
protocol ProfileNavigator: Navigator {
    func showEditProfile()
}

final class ProfileFlow: FlowCoordinator, ProfileNavigator {
    func showEditProfile() {
        let editModule = ScreenModule(viewController: EditProfileViewController())
        push(editModule)
    }
}
```

### Embedding SwiftUI inside UIKit
```swift
struct DashboardView: View {
    var body: some View {
        Text("Dashboard")
            .font(.title)
    }
}

let hostingController = BaseHostingViewController(rootView: DashboardView())
```

### Collapsing header container
```swift
let header = UIView()
header.backgroundColor = .systemBlue
let tableView = UITableView()
let collapsing = CollapsingHeaderViewController(headerView: header, scrollView: tableView, headerHeight: 240)
collapsing.delegate = self
```

### SwiftUI collapsible header
Use `CollapsibleHeaderView` to recreate the same collapsing behavior entirely in SwiftUI. The view listens for scroll direction through `CollapsibleHeaderViewModel` and adjusts the header height between expanded and collapsed states.

```swift
struct SwiftUICollapsibleDemo: View {
    private let viewModel = CollapsibleHeaderViewModel()
    private let items = Array(0..<100)

    var body: some View {
        CollapsibleHeaderView(items, id: \.self, expandedHeight: 220, collapsedHeight: 70, viewModel: viewModel) {
            LinearGradient(colors: [.pink, .purple], startPoint: .top, endPoint: .bottom)
        } rowContent: { item in
            Text("Item #\(item)")
        }
    }
}
```

To bridge this SwiftUI header into existing UIKit flows, wrap it with `BaseHostingViewController` and produce a `ScreenModule` just like any other view controller:

```swift
enum SwiftUICollapsibleHeaderExampleModule {
    static func make() -> ScreenModule {
        let hosting = BaseHostingViewController(rootView: SwiftUICollapsibleDemo())
        return ScreenModule(viewController: hosting)
    }
}
```

See `Examples/SwiftUICollapsibleHeaderExample.swift` for a full sample that can be plugged into a `FlowCoordinator`.

### Paged Lists & Presenters
`PagedListState` and `PagedListViewModel` provide a shared contract for paginated experiences, while `DefaultLoadingPresenter`
and `DefaultErrorPresenter` offer simple UI feedback hooks.

```swift
final class DemoPagedListViewModel: PagedListViewModel {
    typealias Item = String
    private(set) var state = PagedListState<Item>()

    func loadInitial() { /* kick off first page */ }
    func loadMore() { /* request next page */ }
}

let viewModel = DemoPagedListViewModel()
let loadingPresenter = DefaultLoadingPresenter()
loadingPresenter.showLoading(on: viewController)
```

See `Examples/PagedListExample.swift` for a working sample with a table view.

## Contributing
The toolkit is intentionally minimal and unopinionated. Extend the flows, navigators, and containers as needed for your application while keeping business logic outside the package.
