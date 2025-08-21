import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private let appleCaptiveCheckURL = "http://captive.apple.com/hotspot-detect.html"

final public class HotspotCheck: ThrowableCheck {
    private let request: URLRequest
    private(set) var statusCode: Int?
    private var responseUrl: String = ""
    private var requestError: Error?

    override public init() {
        var request = URLRequest(url: URL(string: appleCaptiveCheckURL)!)
        request.httpMethod = "GET"
        self.request = request
    }

    public override func performThrowableCheck() async throws {
        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            status = .failed
            debugInformation = response.debugDescription
            return
        }

        responseUrl = httpResponse.url?.absoluteString ?? ""
        status = (responseUrl == appleCaptiveCheckURL) ? .success : .failed

        if (status == .success) {
            debugInformation = "hotspot not detected"

        } else {
            debugInformation.append("URL has changed, there's probably a hotspot\n")
            debugInformation.append("response URL is " + (responseUrl.isEmpty ? "unknowkn" : "\(responseUrl)"))
        }

    }
}
