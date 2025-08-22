import Foundation
import NetTesterLib

final public class CertificateCheck: NSObject, CheckProtocol {
    public var debugInformation: String { debugBreadcrumbs.joined(separator: "\n")}
    private var debugBreadcrumbs: [String] = []
    public var name: String?
    public private(set) var status: CheckStatus = .notLaunchedYet
    private var session: URLSession?
    private var task: URLSessionTask!
    fileprivate(set) var receivedCertificate: SecCertificate?
    private(set) var receivedSerialNumber: String?
    private(set) var receivedCommonName: String?
    private(set) var receivedEmails: [String]?
    let expectedCertificateData: Data?
    let expectedCommonName: String?
    let url: URL

    public init(url: URL, expectedCertificateData: Data? = nil, expectedCommonName: String? = nil) {
        self.url = url
        self.expectedCertificateData = expectedCertificateData
        self.expectedCommonName = expectedCommonName
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }

    public func performCheck() async -> CheckStatus {
        status = .inProgress
        debugBreadcrumbs = []
        let request = URLRequest(url: url)
        _ = try? await session?.data(for: request)

        if status == .inProgress {
            status = .failed
        }
        return status
    }

    fileprivate func extractCertificateData(_ certificate: SecCertificate) {
        var commonNameRef: CFString?
        SecCertificateCopyCommonName(certificate, &commonNameRef)
        if let commonName = commonNameRef as String?, commonName.count > 0 {
            debugBreadcrumbs.append("CN: \"\(commonName)\"")
            self.receivedCommonName = commonName
        }
        let serialNumberData = SecCertificateCopySerialNumberData(certificate, nil)
        if let data = serialNumberData as Data?, data.count > 0 {
            debugBreadcrumbs.append("SN: \(data.hexademicalString)")
            receivedSerialNumber = data.hexademicalString
        }
        var arrayRef: CFArray?
        SecCertificateCopyEmailAddresses(certificate, &arrayRef)
        if let emails = arrayRef as? [String], emails.count > 0 {
            debugBreadcrumbs.append("EMAILS: \(emails.joined(separator: ", "))")
            receivedEmails = emails
        }
    }

    fileprivate func validate() -> Bool {
        if let expectedCertificateData, expectedCertificateData != receivedCertificate?.data {
            return false
        }
        if let expectedCommonName, expectedCommonName != receivedCommonName {
            return false
        }
        return true
    }

}

extension CertificateCheck: URLSessionDelegate, URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.protocol == NSURLProtectionSpaceHTTPS && challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust else {
            debugBreadcrumbs.append("Got unexpected \(challenge.protectionSpace.authenticationMethod) challenge for \(challenge.protectionSpace.protocol ?? "unknown") protocol. Server trust is " + (challenge.protectionSpace.serverTrust == nil ? "nil" : "not nil"))
                completionHandler(.performDefaultHandling, nil)
                return
        }
        var secresult = SecTrustResultType.invalid
        guard SecTrustEvaluate(serverTrust, &secresult) == errSecSuccess,
            let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                self.status = .failed
            debugBreadcrumbs.append("Certificate validation failed")
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
        }

        self.receivedCertificate = serverCertificate
        extractCertificateData(serverCertificate)

        if validate() {
            status = .success
            debugBreadcrumbs.append("Certificate accepted")
        } else {
            status = .warning
            debugBreadcrumbs.append("Received unexpected but trusted certificate")
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    }

}

private extension String {
    func appendingNewLine(_ line: String) -> String {
        return self.count == 0 ? line : self + "\n" + line
    }
}

private extension Data {
    var hexademicalString: String {
        return self.map { String(format: "%02hhx", $0) }.joined(separator: " ")
    }
}

private extension SecCertificate {
    var data: Data {
        let serverCertificateData = SecCertificateCopyData(self)
        let data = CFDataGetBytePtr(serverCertificateData)
        let size = CFDataGetLength(serverCertificateData)

        return Data(bytes: data!, count: size)
    }
}
