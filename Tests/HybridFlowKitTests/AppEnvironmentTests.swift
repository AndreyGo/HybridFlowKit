import XCTest
@testable import HybridFlowKit

final class AppEnvironmentTests: XCTestCase {
    func testDefaultInitializer() {
        let environment = AppEnvironment()
        XCTAssertTrue(environment.services.resolveIfRegistered(String.self) == nil)
    }

    func testCustomServicesAndLogger() {
        final class StubLogger: LoggerProtocol {
            var messages: [String] = []
            var errors: [Error] = []

            func log(_ message: String) {
                messages.append(message)
            }

            func log(error: Error) {
                errors.append(error)
            }
        }

        let logger = StubLogger()
        let services = ServiceContainer()
        services.register(Int.self, instance: 42)

        let environment = AppEnvironment(
            services: services,
            logger: logger,
            mainQueue: .main,
            backgroundQueue: .global(qos: .background)
        )

        XCTAssertEqual(environment.services.resolve(Int.self), 42)
        environment.logger.log("test")
        XCTAssertEqual(logger.messages, ["test"])
    }
}
