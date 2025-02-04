import Foundation

public class CheckRunner {
    private let queue = DispatchQueue(label: "CheckRunner", qos: .background, attributes: .concurrent)
    public init() {}

    public func run(checks: [any CheckProtocol], completion: @escaping () -> () = {}) {
        for check in checks {
            queue.async {
                check.performCheck()
            }
        }
        queue.async(flags: .barrier, execute: completion)
    }
}
