import UIKit
import HybridFlowKit

protocol AuthService {
    func isAuthorized() -> Bool
}

final class DefaultAuthService: AuthService {
    func isAuthorized() -> Bool { true }
}

final class EnvironmentFlowCoordinator: FlowCoordinator {
    override func start() {
        if let auth: AuthService = environment?.services.resolveIfRegistered(AuthService.self) {
            environment?.logger.log("Authorized: \(auth.isAuthorized())")
        }

        let controller = UIViewController()
        controller.view.backgroundColor = .systemBackground
        controller.title = "Environment Demo"

        push(ScreenModule(viewController: controller), animated: false)
    }
}

/// Example showcasing how to initialize `AppEnvironment` with services and wire it to an `AppStateController`.
func buildEnvironmentExample() -> UIViewController {
    let services = ServiceContainer()
    services.register(AuthService.self, instance: DefaultAuthService())

    let environment = AppEnvironment(services: services, logger: DefaultLogger())
    let appStateController = AppStateController(initialState: .authorized, environment: environment)

    // Custom flow could be injected by overriding makeFlow(for:) in a subclass.
    let flow = EnvironmentFlowCoordinator(environment: environment)
    flow.start()
    appStateController.onFlowFinish = { event in
        environment.logger.log("Flow finished: \(event)")
    }

    return flow.rootViewController
}
