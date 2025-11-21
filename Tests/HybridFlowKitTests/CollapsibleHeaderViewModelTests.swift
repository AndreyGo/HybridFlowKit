#if canImport(SwiftUI)
import XCTest
@testable import HybridFlowKit

final class CollapsibleHeaderViewModelTests: XCTestCase {
    func testInitialStateIsInitial() {
        let viewModel = CollapsibleHeaderViewModel()
        XCTAssertEqual(viewModel.state, .initial)
    }

    func testCollapseWhenIndexesIncrease() {
        let viewModel = CollapsibleHeaderViewModel()

        viewModel.onCellAppear(index: 0)
        viewModel.onCellAppear(index: 1)

        XCTAssertEqual(viewModel.state, .collapse)
    }

    func testExpandWhenIndexesDecrease() {
        let viewModel = CollapsibleHeaderViewModel()

        viewModel.onCellAppear(index: 3)
        viewModel.onCellAppear(index: 1)

        XCTAssertEqual(viewModel.state, .expand)
    }

    func testResetRestoresInitialState() {
        let viewModel = CollapsibleHeaderViewModel()

        viewModel.onCellAppear(index: 1)
        viewModel.reset()

        XCTAssertEqual(viewModel.state, .initial)
        viewModel.onCellAppear(index: 2)
        XCTAssertEqual(viewModel.state, .initial, "First index after reset should not trigger collapse")
    }
}
#endif
