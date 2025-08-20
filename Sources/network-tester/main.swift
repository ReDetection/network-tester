import Foundation
import NetTesterLib

var checks: [CheckProtocol] = []

checks.append(HTTPCheck(url: URL(string: "https://google.com")!, expectedStatusCode: 200))
checks.append(HTTPCheck(url: URL(string: "http://192.168.21.217/")!, expectedStatusCode: 404))
checks.append(HotspotCheck())

let runner = CheckRunner()
runner.didUpdate = { check in
    print(check.debugInformation)
}

await runner.run(checks: checks)
exit(checks.allSatisfy { $0.status == .success } ? 0 : 1 )
