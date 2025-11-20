import XCTest
import UIKit
@testable import HybridFlowKit

final class ModalFlowCoordinatorTests: XCTestCase {
    func testInitializerUsesNavigationControllerByDefault() {
        let coordinator = ModalFlowCoordinator()
        XCTAssertTrue(coordinator.rootViewController is UINavigationController)
    }

    func testStartDoesNotCrash() {
        let coordinator = ModalFlowCoordinator()
        coordinator.start()
    }

    func testFinishInvokesOnFinish() {
        let coordinator = ModalFlowCoordinator()
        let expectation = expectation(description: "onFinish called")

        coordinator.onFinish = { event in
            XCTAssertEqual(event, .completed)
            expectation.fulfill()
        }

        coordinator.finish(.completed)
        waitForExpectations(timeout: 1)
    }
}
