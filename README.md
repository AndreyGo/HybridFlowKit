# HybridFlowKit

HybridFlowKit is a lightweight architectural toolkit for building hybrid iOS applications that mix UIKit and SwiftUI. It provides a common Flow/Coordinator mechanism, navigation helpers, UIKit containers for hosting SwiftUI, and utilities to rapidly assemble screen modules without coupling to business logic.

## Features
- Flow protocol with base coordinator and finish events.
- App state controller to swap flows for onboarding, authorization, splash, and more.
- Navigation helpers and context abstractions for UIKit-based routing.
- UIKit containers that host SwiftUI and support a collapsing header pattern.
- Screen module abstraction and factory protocol for type-safe module creation.
- Minimal logger and convenience extensions to streamline integration.

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

## Contributing
The toolkit is intentionally minimal and unopinionated. Extend the flows, navigators, and containers as needed for your application while keeping business logic outside the package.
