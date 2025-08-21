import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public class HTTPCheck: CheckProtocol {
    public var status: CheckStatus
    public var name: String?
    var request: URLRequest
    var statusCode: Int?
    var expectedCode: Int
    let timeout: TimeInterval

    public var debugInformation: String = ""

    public init(url: URL, expectedStatusCode: Int = 200, timeout: TimeInterval = 10) {
        status = CheckStatus.notLaunchedYet
        request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout
        expectedCode = expectedStatusCode
        self.timeout = timeout
    }

    @discardableResult
    public func performCheck() async -> CheckStatus {
        status = .inProgress

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                status = .failed
                debugInformation = "no response"
                return status
            }

            statusCode = httpResponse.statusCode
            status = httpResponse.statusCode == expectedCode ? .success : .failed

            if let statusCodeString: String = statusCode?.asString {
                debugInformation = "status code is \(statusCodeString)\nresponse is \(data.count)"
            }
        } catch {
            debugInformation = error.localizedDescription
            status = .failed
        }
        return status
    }
}

extension Int {
    var asString: String {
        return String(self)
    }
}
