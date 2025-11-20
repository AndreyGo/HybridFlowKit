import UIKit

/// Represents the high-level state of the application used to determine which flow should be launched.
public enum AppState {
    case splash
    case onboarding
    case authorized
    case guest
    case banned
}

/// Controls the lifecycle of the currently active `Flow` based on the active `AppState`.
/// The default implementation uses a placeholder flow and is intended to be subclassed or
/// composed with a factory to provide app-specific flows.
open class AppStateController {
    /// The state currently driving the active flow.
    public private(set) var currentState: AppState

    /// The flow currently hosted by the controller.
    public private(set) var currentFlow: Flow?

    /// Called whenever the active flow finishes with an event.
    public var onFlowFinish: ((FlowFinishEvent) -> Void)?

    /// Creates a new controller with the provided initial state.
    /// - Parameter initialState: The initial application state. Defaults to `.splash`.
    public init(initialState: AppState = .splash) {
        currentState = initialState
        currentFlow = makeFlow(for: initialState)
        currentFlow?.onFinish = { [weak self] event in
            self?.handleFlowFinish(event)
        }
    }

    /// Updates the application state and replaces the running flow accordingly.
    /// - Parameter state: The new application state to activate.
    open func setState(_ state: AppState) {
        guard state != currentState else { return }
        currentState = state
        let flow = makeFlow(for: state)
        flow.onFinish = { [weak self] event in
            self?.handleFlowFinish(event)
        }
        currentFlow = flow
        flow.start()
        Logger.logFlowTransition("Switched to state: \(state)")
    }

    /// Creates a flow for the provided state. Override to provide concrete flows from the host app.
    /// - Parameter state: The state for which to build a flow.
    /// - Returns: A flow ready to be started.
    open func makeFlow(for state: AppState) -> Flow {
        PlaceholderFlow(state: state)
    }

    /// Returns the root view controller of the currently active flow.
    /// - Returns: The flow's root view controller or an empty placeholder controller.
    open func currentRootViewController() -> UIViewController {
        currentFlow?.rootViewController ?? UIViewController()
    }

    private func handleFlowFinish(_ event: FlowFinishEvent) {
        onFlowFinish?(event)

        switch event {
        case .switchToAuthorized:
            setState(.authorized)
        case .switchToOnboarding:
            setState(.onboarding)
        case .switchToGuest:
            setState(.guest)
        case .switchToBanned:
            setState(.banned)
        default:
            break
        }
    }
}

private final class PlaceholderFlow: Flow {
    var onFinish: ((FlowFinishEvent) -> Void)?

    let rootViewController: UIViewController

    init(state: AppState) {
        let controller = UIViewController()
        controller.view.backgroundColor = .systemBackground
        controller.title = "Placeholder for \(state)"
        rootViewController = controller
    }

    func start() {
        Logger.logFlowTransition("Starting placeholder flow")
    }
}
