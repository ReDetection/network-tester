import SwiftTUI
import Foundation
import NetTesterLib
#if os(macOS)
import ApplePlatformChecks
#endif

struct App: View {
    @State var checks: [CheckProtocol] = {
        var checks: [CheckProtocol] = []
        checks.append(HTTPCheck(url: URL(string: "https://google.com")!, expectedStatusCodes: [200]).named("Google reachable"))
        checks.append(HTTPCheck(url: URL(string: "http://192.168.21.105/")!, expectedStatusCodes: [404]).named("Smart home reachable"))
        checks.append(HotspotCheck().named("Hospot unrestricted"))
        checks.append(DNSResolverCheck(hostname: "apple.com").named("DNS can resolve apple.com"))
        #if os(macOS)
        checks.append(CertificateCheck(url: URL(string: "https://google.com")!, expectedCertificateData: Data()).named("Could read certificates"))
        #endif
        return checks
    }()
    @State var refreshCheat: Int = 0

    let runner = CheckRunner()

    var body: some View {
        VStack(spacing: 1) {
            VStack {
                ForEach(Array(checks.enumerated()), id: \.offset) { check in
                    CheckView(check: check.element)
                }
            }
            Spacer()
            Button("Refresh") {
                scheduleUpdate()
            }
            Button("Exit") {
                exit(0)
            }
        }
        .onAppear {
            scheduleUpdate()
        }
    }

    private func scheduleUpdate() {
        runner.didUpdate = { _ in
            refreshCheat += 1
        }
        Task {
            await runner.run(checks: checks)
        }
    }

}
struct CheckView: View {
    let check: CheckProtocol

    var body: some View {
        VStack {
            HStack {
                Text(check.status.emoji)
                Text(check.name ?? "\(check)")
            }
            if [.warning, .failed].contains(check.status) {
                Text("")
                ForEach(Array(check.debugInformation.split(separator: "\n").map {"    \($0)"}.enumerated()), id: \.offset) {
                    Text($0.element)
                }
                Text("")
            }
        }
    }
}
extension CheckStatus {
    var emoji: String {
        switch self {
        case .notLaunchedYet: "❓"
        case .inProgress: "🛠️"
        case .success: "✅"
        case .warning: "🟡"
        case .failed: "❌"
        }
    }
}
