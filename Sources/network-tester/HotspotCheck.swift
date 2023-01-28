import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let appleCaptiveCheckURL = "http://captive.apple.com/hotspot-detect.html"

class HotspotCheck: CheckProtocol {
    var status: CheckStatus
    var callback: ()->() = {}
    var isFinished: Bool
    var request: URLRequest
    var statusCode: Int?
    var responseUrl: String = ""

    var debugInformation: String {
        var debugInfoString: String = "checking for hotspot via URL \(request.url!)\n"
        debugInfoString.append("response URL is " + (responseUrl.isEmpty ? "unknowkn" : "\(responseUrl)\n"))
        if (status == .success) {
            debugInfoString.append("hotspot not detected\n")
        } else {
            debugInfoString.append("URL has changed, there's probably a hotspot\n")
        }

        return debugInfoString
    }

    init() {
        status = CheckStatus.notLaunchedYet
        isFinished = false
        request = URLRequest(url: URL(string: appleCaptiveCheckURL)!)
        request.httpMethod = "GET"
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

            self.responseUrl = httpResponse.url?.absoluteString ?? ""
            self.status = (self.responseUrl == appleCaptiveCheckURL) ? .success : .failed
        }
        task.resume()
    }
}
