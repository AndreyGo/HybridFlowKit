import XCTest
@testable import HybridFlowKit

final class PagedListStateTests: XCTestCase {
    func testDefaultInitialization() {
        let state = PagedListState<String>()
        XCTAssertTrue(state.items.isEmpty)
        XCTAssertFalse(state.isLoadingInitial)
        XCTAssertFalse(state.isLoadingMore)
        XCTAssertTrue(state.canLoadMore)
        XCTAssertNil(state.error)
    }

    func testCustomFlagsAndError() {
        enum SampleError: Error { case failed }
        var state = PagedListState(items: [1, 2, 3], isLoadingInitial: true, isLoadingMore: true, canLoadMore: false, error: SampleError.failed)
        XCTAssertEqual(state.items.count, 3)
        XCTAssertTrue(state.isLoadingInitial)
        XCTAssertTrue(state.isLoadingMore)
        XCTAssertFalse(state.canLoadMore)
        XCTAssertNotNil(state.error)

        state.isLoadingInitial = false
        state.isLoadingMore = false
        state.canLoadMore = true
        state.error = nil

        XCTAssertFalse(state.isLoadingInitial)
        XCTAssertFalse(state.isLoadingMore)
        XCTAssertTrue(state.canLoadMore)
        XCTAssertNil(state.error)
    }
}
