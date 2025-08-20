import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let appleCaptiveCheckURL = "http://captive.apple.com/hotspot-detect.html"

public class HotspotCheck: CheckProtocol {
    public var status: CheckStatus
    public var isFinished: Bool
    public var name: String?
    var request: URLRequest
    var statusCode: Int?
    var responseUrl: String = ""
    var requestError: Error?

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

            responseUrl = httpResponse.url?.absoluteString ?? ""
            status = (responseUrl == appleCaptiveCheckURL) ? .success : .failed
        } catch {
            status = .failed
            requestError = error
        }

        isFinished = true
        return status
    }
}
