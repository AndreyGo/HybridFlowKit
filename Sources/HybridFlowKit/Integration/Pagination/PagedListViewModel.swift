import Foundation

/// Describes a view model capable of driving a paginated list.
public protocol PagedListViewModel: AnyObject {
    associatedtype Item

    /// Current state of the paginated list.
    var state: PagedListState<Item> { get }

    /// Loads the initial batch of data.
    func loadInitial()

    /// Loads the next page when available.
    func loadMore()
}
