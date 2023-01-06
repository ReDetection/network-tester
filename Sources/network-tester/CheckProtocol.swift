import Foundation

enum CheckStatus {
    case notLaunchedYet
    case inProgress
    case success
    case failed
}

protocol CheckProtocol {
    var status: CheckStatus { get }

    func performCheck()
}
