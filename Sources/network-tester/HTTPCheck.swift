import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class HTTPCheck: CheckProtocol {
    var status: CheckStatus
    var callback: ()->() = {}
    var request: URLRequest
    var statusCode: Int?

    init(url: URL) {
        request = URLRequest(url: url)
        request.httpMethod = "GET"
        status = CheckStatus.notLaunchedYet
    }

    func performCheck() {
        status = .inProgress

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer{
                self.callback()
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.status = .failed
                return
            }

            self.statusCode = httpResponse.statusCode
            self.status = httpResponse.statusCode == 200 ? .success : .failed
        }
        task.resume()
    }
}
