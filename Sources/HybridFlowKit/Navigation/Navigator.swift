import Foundation

/// Marker protocol describing objects capable of navigating inside a feature or flow.
/// Concrete navigators provide typed entry points for screens while staying testable and decoupled from UIKit.
public protocol Navigator: AnyObject {}
