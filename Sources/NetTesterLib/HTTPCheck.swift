import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class HTTPCheck: CheckProtocol {
    public var status: CheckStatus
    public var isFinished: Bool
    public var name: String?
    var request: URLRequest
    var statusCode: Int?
    var expectedCode: Int
    let timeout: TimeInterval

    public var debugInformation: String {
        var debugInfoString: String = "checking URL \(request.url!) with a timeout of \(timeout)s...\n"
        debugInfoString.append("check status: \(status)\n")

        if let statusCodeString: String = statusCode?.asString {
            debugInfoString.append("status code is " + statusCodeString + "\n")
        } else if isFinished{
            debugInfoString.append("no response\n")
        }

        return debugInfoString
    }

    public init(url: URL, expectedStatusCode: Int = 200, timeout: TimeInterval = 10) {
        status = CheckStatus.notLaunchedYet
        isFinished = false
        request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout
        expectedCode = expectedStatusCode
        self.timeout = timeout
    }

    @discardableResult
    public func performCheck() async -> CheckStatus {
        status = .inProgress
        isFinished = false

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                status = .failed
                isFinished = true
                return status
            }

            statusCode = httpResponse.statusCode
            status = httpResponse.statusCode == expectedCode ? .success : .failed
            isFinished = true
            return status
        } catch {
            status = .failed
            isFinished = true
            return status
        }
    }
}

extension Int {
    var asString: String {
        return String(self)
    }
}
