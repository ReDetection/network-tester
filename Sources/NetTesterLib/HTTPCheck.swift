import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final public class HTTPCheck: ThrowableCheck {
    let request: URLRequest
    private(set) var statusCode: Int?
    let expectedCode: Int
    let timeout: TimeInterval

    public init(url: URL, expectedStatusCode: Int = 200, timeout: TimeInterval = 10) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout
        expectedCode = expectedStatusCode
        self.timeout = timeout
        self.request = request
    }

    public override func performThrowableCheck() async throws {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            status = .failed
            debugInformation = "no response"
            return
        }

        statusCode = httpResponse.statusCode
        status = httpResponse.statusCode == expectedCode ? .success : .failed

        if let statusCodeString: String = statusCode?.asString {
            debugInformation = "status code is \(statusCodeString)\nresponse is \(data.count)"
        }
    }
}

extension Int {
    var asString: String {
        return String(self)
    }
}
