/// Describes a factory capable of building screen modules for a given route.
public protocol ScreenFactory {
    associatedtype Route

    /// Creates a module for the provided route value.
    /// - Parameter route: Type-safe route describing the destination.
    /// - Returns: A fully prepared `ScreenModule`.
    func make(route: Route) -> ScreenModule
}
