#if canImport(SwiftUI)
import SwiftUI

/// Represents the current collapsing state of a SwiftUI header.
@available(iOS 13.0, *)
public enum CollapsibleHeaderState {
    /// Initial untouched state.
    case initial
    /// Indicates the header should collapse (e.g., user is scrolling down).
    case collapse
    /// Indicates the header should expand (e.g., user scrolls up).
    case expand
}

/// Observable object that tracks scroll direction based on cell appearance and emits header state updates.
@available(iOS 13.0, *)
public final class CollapsibleHeaderViewModel: ObservableObject {
    @Published public private(set) var state: CollapsibleHeaderState = .initial
    private var previousIndex: Int?

    public init() {}

    /// Resets the header state and clears cached index.
    public func reset() {
        state = .initial
        previousIndex = nil
    }

    /// Notifies the view model that a cell at the given index appeared.
    /// - Parameter index: Index of the cell that became visible.
    public func onCellAppear(index: Int) {
        guard index >= 0 else { return }

        if let previousIndex {
            if index > previousIndex {
                state = .collapse
            } else if index < previousIndex {
                state = .expand
            }
        }

        previousIndex = index
    }
}

private struct IndexedElement<ID: Hashable, Element> {
    let index: Int
    let id: ID
    let element: Element
}

/// A ready-to-use SwiftUI view that adjusts its header height based on scroll direction.
@available(iOS 13.0, *)
public struct CollapsibleHeaderView<Data: RandomAccessCollection, ID: Hashable, Header: View, RowContent: View>: View {
    @StateObject private var viewModel: CollapsibleHeaderViewModel
    @State private var headerHeight: CGFloat

    private let data: [IndexedElement<ID, Data.Element>]
    private let expandedHeight: CGFloat
    private let collapsedHeight: CGFloat
    private let header: () -> Header
    private let rowContent: (Data.Element) -> RowContent

    /// Creates a collapsible header list using the provided data source and header content.
    /// - Parameters:
    ///   - data: Items to render inside the list.
    ///   - id: Key path used to uniquely identify each element.
    ///   - expandedHeight: Height when the header is fully visible. Defaults to 200.
    ///   - collapsedHeight: Height when collapsed after scrolling. Defaults to 60.
    ///   - viewModel: A view model instance. Defaults to a new instance, but can be injected for testing.
    ///   - header: Builder for the header view.
    ///   - rowContent: Builder for row content.
    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        expandedHeight: CGFloat = 200,
        collapsedHeight: CGFloat = 60,
        viewModel: CollapsibleHeaderViewModel = CollapsibleHeaderViewModel(),
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data.enumerated().map { offset, element in
            IndexedElement(index: offset, id: element[keyPath: id], element: element)
        }
        self.expandedHeight = expandedHeight
        self.collapsedHeight = collapsedHeight
        _viewModel = StateObject(wrappedValue: viewModel)
        _headerHeight = State(initialValue: expandedHeight)
        self.header = header
        self.rowContent = rowContent
    }

    public var body: some View {
        VStack(spacing: 0) {
            header()
                .frame(height: headerHeight)
                .frame(maxWidth: .infinity)

            List(data, id: \._id) { row in
                rowContent(row.element)
                    .onAppear {
                        viewModel.onCellAppear(index: row.index)
                    }
            }
            .listStyle(.plain)
            .onReceive(viewModel.$state) { state in
                switch state {
                case .collapse:
                    headerHeight = collapsedHeight
                case .expand:
                    headerHeight = expandedHeight
                case .initial:
                    break
                }
            }
        }
    }
}

private extension IndexedElement {
    var _id: ID { id }
}
#endif
