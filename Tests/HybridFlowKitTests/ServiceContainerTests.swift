import XCTest
@testable import HybridFlowKit

final class ServiceContainerTests: XCTestCase {
    func testRegistersAndResolvesSingleService() {
        let container = ServiceContainer()
        container.register(String.self, instance: "value")

        let resolved: String = container.resolve(String.self)
        XCTAssertEqual(resolved, "value")
    }

    func testRegistersMultipleServices() {
        let container = ServiceContainer()
        container.register(String.self, instance: "text")
        container.register(Int.self, instance: 10)

        let stringValue: String = container.resolve(String.self)
        let intValue: Int = container.resolve(Int.self)

        XCTAssertEqual(stringValue, "text")
        XCTAssertEqual(intValue, 10)
    }

    func testResolveIfRegisteredReturnsNilForMissingService() {
        let container = ServiceContainer()
        XCTAssertNil(container.resolveIfRegistered(Bool.self))
    }
}
