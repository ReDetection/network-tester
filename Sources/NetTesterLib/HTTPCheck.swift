import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final public class HTTPCheck: ThrowableCheck {
    let url: URL
    let request: URLRequest
    private(set) var statusCode: Int?
    let expectedStatusCodes: [Int]
    let timeout: TimeInterval

    public init(url: URL, expectedStatusCodes: [Int] = [200], method: String = "GET", timeout: TimeInterval = 10) {
        self.url = url
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = timeout
        self.expectedStatusCodes = expectedStatusCodes
        self.timeout = timeout
        self.request = request
    }

    public override func performThrowableCheck() async throws {
        let (data, response) = try await URLSession.shared.data(for: request)
        debugBreadcrumbs.append("request url: \(url.absoluteString)")

        guard let httpResponse = response as? HTTPURLResponse else {
            status = .failed
            debugBreadcrumbs.append("no response")
            return
        }

        if let responseUrl = httpResponse.url, responseUrl != url {
            debugBreadcrumbs.append("response url: \(responseUrl.absoluteString)")
        }
        statusCode = httpResponse.statusCode
        status = expectedStatusCodes.contains(httpResponse.statusCode) ? .success : .failed

        if let statusCodeString: String = statusCode?.asString {
            debugBreadcrumbs.append("status code is \(statusCodeString)\nbody length is \(data.count)")
        }
    }
}

extension Int {
    var asString: String {
        return String(self)
    }
}
