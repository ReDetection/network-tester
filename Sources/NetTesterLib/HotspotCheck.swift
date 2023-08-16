import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let appleCaptiveCheckURL = "http://captive.apple.com/hotspot-detect.html"

public class HotspotCheck: CheckProtocol {
    public var status: CheckStatus
    public var callback: ()->() = {}
    public var isFinished: Bool
    public var name: String?
    var request: URLRequest
    var statusCode: Int?
    var responseUrl: String = ""

    public var debugInformation: String {
        var debugInfoString: String = "checking for hotspot via URL \(request.url!)\n"
        debugInfoString.append("response URL is " + (responseUrl.isEmpty ? "unknowkn" : "\(responseUrl)\n"))
        if (status == .success) {
            debugInfoString.append("hotspot not detected\n")
        } else {
            debugInfoString.append("URL has changed, there's probably a hotspot\n")
        }

        return debugInfoString
    }

    public init() {
        status = CheckStatus.notLaunchedYet
        isFinished = false
        request = URLRequest(url: URL(string: appleCaptiveCheckURL)!)
        request.httpMethod = "GET"
    }

    public func performCheck() {
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
