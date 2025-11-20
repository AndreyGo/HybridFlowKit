/// Defines the events that can complete or transition between flows.
public enum FlowFinishEvent {
    case completed
    case cancelled
    case logout
    case switchToAuthorized
    case switchToOnboarding
    case switchToGuest
    case switchToBanned
}
