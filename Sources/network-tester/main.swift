import Foundation
import NetTesterLib
#if os(macOS)
import ApplePlatformChecks
#endif

var checks: [CheckProtocol] = []

checks.append(HTTPCheck(url: URL(string: "https://google.com")!, expectedStatusCode: 200))
checks.append(HTTPCheck(url: URL(string: "http://192.168.21.194/")!, expectedStatusCode: 404))
checks.append(HotspotCheck())
checks.append(DNSResolverCheck(hostname: "apple.com"))
#if os(macOS)
checks.append(CertificateCheck(url: URL(string: "https://google.com")!, expectedCertificateData: Data()))
#endif

let runner = CheckRunner()
runner.didUpdate = { check in
    if check.debugInformation.isEmpty {
        print("check \(check) finished")

    } else {
        print("check \(check) finished:")
        print(check.debugInformation)
    }
    print()
}

await runner.run(checks: checks)
exit(checks.allSatisfy { $0.status == .success } ? 0 : 1 )
