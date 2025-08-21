import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final public class CertificateCheck: NSObject, CheckProtocol {
    public var debugInformation: String = ""
    public var name: String?
    public private(set) var status: CheckStatus = .notLaunchedYet

    //todo remove
    private(set) var localizedCheckResult: String?
    private(set) var enCheckResult: String?
    private var session: URLSession?
    private var task: URLSessionTask!
    fileprivate(set) var receivedCertificate: SecCertificate?
    let expectedCertificateData: Data
    let url: URL

    public init(url: URL, expectedCertificateData: Data) {
        self.url = url
        self.expectedCertificateData = expectedCertificateData
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }

    public func performCheck() async -> CheckStatus {
        status = .inProgress
        let request = URLRequest(url: url)
        _ = try? await session?.data(for: request)

        extractCertificateData()
        if status == .inProgress {
            status = .failed
        }
        return status
    }

    func extractCertificateData() {
        if let certificate = self.receivedCertificate, status != .success {
            var commonNameRef: CFString?
            SecCertificateCopyCommonName(certificate, &commonNameRef)
            if let commonName = commonNameRef as String?, commonName.count > 0 {
                self.append(en: "CN: \"\(commonName)\"", localized: nil)
            }
            let serialNumberData = SecCertificateCopySerialNumberData(certificate, nil)
            if let data = serialNumberData as Data?, data.count > 0 {
                self.append(en: "SN: " + data.hexademicalString, localized: nil)
            }
            var arrayRef: CFArray?
            SecCertificateCopyEmailAddresses(certificate, &arrayRef)
            if let emails = arrayRef as? [String], emails.count > 0 {
                self.append(en: "EMAILS: " + emails.joined(separator: ", "), localized: nil)
            }

            debugInformation = enCheckResult ?? ""
        }
    }

}

extension CertificateCheck: URLSessionDelegate, URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.protocol == NSURLProtectionSpaceHTTPS && challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust else {
                self.append(en: "Got unexpected \(challenge.protectionSpace.authenticationMethod) challenge for \(challenge.protectionSpace.protocol ?? "unknown") protocol. Server trust is " + (challenge.protectionSpace.serverTrust == nil ? "nil" : "not nil"), localized: nil)
                completionHandler(.performDefaultHandling, nil)
                return
        }
        var secresult = SecTrustResultType.invalid
        guard SecTrustEvaluate(serverTrust, &secresult) == errSecSuccess,
            let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                self.status = .failed
                self.append(en: "Certificate validation failed", localized: NSLocalizedString("Certificate validation failed", comment: "We were able to get the certificate but validation failed"))
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
        }

        self.receivedCertificate = serverCertificate
        let receivedCertificateData = serverCertificate.data

        self.status = receivedCertificateData == expectedCertificateData ? .success : .failed
        if self.status == .success {
            self.append(en: "Received expected certificate", localized: NSLocalizedString("Received expected certificate", comment: "We were able to identify certificate"))
        } else {
            self.append(en: "Received unexpected but trusted certificate", localized: NSLocalizedString("Received unexpected but trusted certificate", comment: "We were able to get certificate and it's trusted (by the user or the system), but app doesn't know it"))
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    fileprivate func append(en: String, localized: String?) {
        if let localized = localized {
            self.localizedCheckResult = self.localizedCheckResult?.appendingNewLine(localized) ?? localized
        }
        self.enCheckResult = self.enCheckResult?.appendingNewLine(en) ?? en
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("the task is done")
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
