import Foundation
import NetTesterLib

final public class CertificateCheck: NSObject, CheckProtocol {
    public var debugInformation: String = ""
    public var name: String?
    public private(set) var status: CheckStatus = .notLaunchedYet
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
        debugInformation = ""
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
                debugInformation.append("CN: \"\(commonName)\"\n")
            }
            let serialNumberData = SecCertificateCopySerialNumberData(certificate, nil)
            if let data = serialNumberData as Data?, data.count > 0 {
                debugInformation.append("SN: \(data.hexademicalString)\n")
            }
            var arrayRef: CFArray?
            SecCertificateCopyEmailAddresses(certificate, &arrayRef)
            if let emails = arrayRef as? [String], emails.count > 0 {
                debugInformation.append("EMAILS: \(emails.joined(separator: ", "))\n")
            }
        }
    }

}

extension CertificateCheck: URLSessionDelegate, URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.protocol == NSURLProtectionSpaceHTTPS && challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust else {
                debugInformation.append("Got unexpected \(challenge.protectionSpace.authenticationMethod) challenge for \(challenge.protectionSpace.protocol ?? "unknown") protocol. Server trust is " + (challenge.protectionSpace.serverTrust == nil ? "nil" : "not nil"))
                debugInformation.append("\n")
                completionHandler(.performDefaultHandling, nil)
                return
        }
        var secresult = SecTrustResultType.invalid
        guard SecTrustEvaluate(serverTrust, &secresult) == errSecSuccess,
            let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                self.status = .failed
                debugInformation.append("Certificate validation failed\n")
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
        }

        self.receivedCertificate = serverCertificate
        let receivedCertificateData = serverCertificate.data

        if receivedCertificateData == expectedCertificateData {
            status = .success
            debugInformation.append("Received expected certificate\n")
        } else {
            status = .warning
            debugInformation.append("Received unexpected but trusted certificate\n")
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
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
