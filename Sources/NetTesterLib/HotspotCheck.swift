import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let appleCaptiveCheckURL = "http://captive.apple.com/hotspot-detect.html"

public class HotspotCheck: CheckProtocol {
    public var status: CheckStatus
    public var name: String?
    var request: URLRequest
    var statusCode: Int?
    var responseUrl: String = ""
    var requestError: Error?

    public var debugInformation: String = ""

    public init() {
        status = CheckStatus.notLaunchedYet
        request = URLRequest(url: URL(string: appleCaptiveCheckURL)!)
        request.httpMethod = "GET"
    }

    @discardableResult
    public func performCheck() async -> CheckStatus {
        status = .inProgress

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                status = .failed
                debugInformation = response.debugDescription
                return status
            }

            responseUrl = httpResponse.url?.absoluteString ?? ""
            status = (responseUrl == appleCaptiveCheckURL) ? .success : .failed

            if (status == .success) {
                debugInformation = "hotspot not detected"

            } else {
                debugInformation.append("URL has changed, there's probably a hotspot\n")
                debugInformation.append("response URL is " + (responseUrl.isEmpty ? "unknowkn" : "\(responseUrl)"))
            }
        } catch {
            status = .failed
            requestError = error
            debugInformation = error.localizedDescription
        }
        return status
    }
}
