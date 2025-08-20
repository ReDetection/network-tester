import Foundation

public class CheckRunner {
    public var didUpdate: (any CheckProtocol)->() = { _ in }
    public init() {}

    public func run(checks: [any CheckProtocol]) async {
        await withTaskGroup(of: Void.self) { [weak self] group in
            for check in checks {
                group.addTask {
                    await check.performCheck()
                    self?.didUpdate(check)
                }
            }
        }
    }
}
