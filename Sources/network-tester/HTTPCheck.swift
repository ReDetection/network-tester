import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class HTTPCheck: CheckProtocol {
    var status: CheckStatus
    var callback: ()->() = {}
    var isFinished: Bool
    var request: URLRequest
    var statusCode: Int?
    var expectedCode: Int

    var debugInformation: String {
        var debugInfoString: String = "checking URL \(request.url!)\n"
        debugInfoString.append("check status is \(status)\n")

        if let statusCodeString: String = statusCode?.asString {
            debugInfoString.append("status code is " + statusCodeString + "\n")
        } else if isFinished{
            debugInfoString.append("no response\n")
        }

        return debugInfoString
    }

    init(url: URL, expectedStatusCode: Int = 200) {
        status = CheckStatus.notLaunchedYet
        isFinished = false
        // debugInformation = "Check not launched, status is unknown"
        request = URLRequest(url: url)
        request.httpMethod = "GET"
        expectedCode = expectedStatusCode
    }

    func performCheck() {
        status = .inProgress
        isFinished = false

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer{
                self.callback()
                self.isFinished = true
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.status = .failed
                return
            }

            self.statusCode = httpResponse.statusCode
            self.status = httpResponse.statusCode == self.expectedCode ? .success : .failed
        }
        task.resume()
    }
}

extension Int {
    var asString: String {
        return String(self)
    }
}
