import XCTest
import UIKit
@testable import HybridFlowKit

final class AppStateControllerTests: XCTestCase {
    func testSetStateCreatesAndStartsNewFlow() {
        let controller = TestAppStateController(initialState: .splash)

        controller.setState(.onboarding)

        XCTAssertEqual(controller.currentState, .onboarding)
        let flow = controller.currentFlow as? TestFlow
        XCTAssertEqual(flow?.state, .onboarding)
        XCTAssertEqual(flow?.startCallCount, 1)
        XCTAssertEqual(controller.createdStates, [.splash, .onboarding])
    }

    func testFlowFinishTransitionsStateAndNotifiesListener() {
        let controller = TestAppStateController(initialState: .guest)
        var receivedEvent: FlowFinishEvent?
        let finishExpectation = expectation(description: "onFlowFinish called")

        controller.onFlowFinish = { event in
            receivedEvent = event
            finishExpectation.fulfill()
        }

        let flow = controller.currentFlow as! TestFlow
        flow.complete(with: .switchToAuthorized)

        XCTAssertEqual(controller.currentState, .authorized)
        XCTAssertEqual(controller.createdStates, [.guest, .authorized])
        XCTAssertEqual((controller.currentFlow as? TestFlow)?.startCallCount, 1)
        XCTAssertEqual(receivedEvent, .switchToAuthorized)

        wait(for: [finishExpectation], timeout: 1.0)
    }
}

private final class TestAppStateController: AppStateController {
    private(set) var createdStates: [AppState] = []
    private var flows: [AppState: TestFlow] = [:]

    override func makeFlow(for state: AppState) -> Flow {
        createdStates.append(state)
        let flow = TestFlow(state: state)
        flows[state] = flow
        return flow
    }
}

private final class TestFlow: Flow {
    let state: AppState
    let rootViewController = UIViewController()
    var onFinish: ((FlowFinishEvent) -> Void)?
    private(set) var startCallCount = 0

    init(state: AppState) {
        self.state = state
    }

    func start() {
        startCallCount += 1
    }

    func complete(with event: FlowFinishEvent) {
        onFinish?(event)
    }
}
