import Foundation

/// Universal state container for paginated lists.
public struct PagedListState<Item> {
    public var items: [Item]
    public var isLoadingInitial: Bool
    public var isLoadingMore: Bool
    public var canLoadMore: Bool
    public var error: Error?

    public init(
        items: [Item] = [],
        isLoadingInitial: Bool = false,
        isLoadingMore: Bool = false,
        canLoadMore: Bool = true,
        error: Error? = nil
    ) {
        self.items = items
        self.isLoadingInitial = isLoadingInitial
        self.isLoadingMore = isLoadingMore
        self.canLoadMore = canLoadMore
        self.error = error
    }
}
