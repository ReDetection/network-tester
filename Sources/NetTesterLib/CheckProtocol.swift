import Foundation

public enum CheckStatus: Sendable {
    case notLaunchedYet
    case inProgress
    case success
    case failed
}

/// Strictly speaking, it is not sendable, but I only send it once mutations are done..
public protocol CheckProtocol: AnyObject, Sendable {
    var status: CheckStatus { get }
    var debugInformation: String { get }
    var name: String? { get set }

    @discardableResult
    func performCheck() async -> CheckStatus
}

extension CheckProtocol {
    public func named(_ name: String) -> Self {
        self.name = name
        return self
    }
}
