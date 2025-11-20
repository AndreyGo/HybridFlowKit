import XCTest
import UIKit
@testable import HybridFlowKit

final class FlowCoordinatorTests: XCTestCase {
    func testPushRetainsModuleAndPushesController() {
        let navigationController = RecordingNavigationController()
        let coordinator = FlowCoordinator(navigationController: navigationController)

        var retainObject: NSObject? = NSObject()
        weak var weakRetainObject = retainObject
        var module: ScreenModule? = ScreenModule(viewController: UIViewController(), retainCycle: retainObject)

        retainObject = nil
        coordinator.push(module!, animated: false)
        module = nil

        XCTAssertEqual(navigationController.pushedViewControllers.count, 1)
        XCTAssertNotNil(weakRetainObject)
    }

    func testPresentStoresModuleAndPresentsController() {
        let navigationController = RecordingNavigationController()
        let coordinator = FlowCoordinator(navigationController: navigationController)
        let module = ScreenModule(viewController: UIViewController())

        coordinator.present(module, animated: true)

        XCTAssertTrue(navigationController.presentedViewController === module.viewController)
        XCTAssertEqual(navigationController.presentAnimated, true)
    }

    func testPopDelegatesToNavigationController() {
        let navigationController = RecordingNavigationController()
        let coordinator = FlowCoordinator(navigationController: navigationController)

        coordinator.pop(animated: false)

        XCTAssertEqual(navigationController.popCallCount, 1)
        XCTAssertEqual(navigationController.popAnimated, false)
    }

    func testFinishNotifiesListener() {
        let navigationController = RecordingNavigationController()
        let coordinator = FlowCoordinator(navigationController: navigationController)
        let expectation = expectation(description: "onFinish called")

        coordinator.onFinish = { event in
            XCTAssertEqual(event, .completed)
            expectation.fulfill()
        }

        coordinator.finish(.completed)

        wait(for: [expectation], timeout: 1.0)
    }
}

private final class RecordingNavigationController: UINavigationController {
    private(set) var pushedViewControllers: [UIViewController] = []
    private(set) var presentAnimated: Bool?
    private(set) var popCallCount: Int = 0
    private(set) var popAnimated: Bool?
    private var recordedPresentedViewController: UIViewController?
    override var presentedViewController: UIViewController? {
        recordedPresentedViewController ?? super.presentedViewController
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewControllers.append(viewController)
        super.pushViewController(viewController, animated: false)
    }

    override func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        recordedPresentedViewController = viewControllerToPresent
        presentAnimated = animated
        completion?()
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        popCallCount += 1
        popAnimated = animated
        return nil
    }
}
