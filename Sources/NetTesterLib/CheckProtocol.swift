import Foundation

public enum CheckStatus {
    case notLaunchedYet
    case inProgress
    case success
    case failed
}

public protocol CheckProtocol: AnyObject {
    var status: CheckStatus { get }
    var callback: ()->() { get set }
    var isFinished: Bool { get }
    var debugInformation: String { get }

    func performCheck()
}
