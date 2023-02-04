import Foundation
import NetTesterLib

var checks: [CheckProtocol] = []

checks.append(HTTPCheck(url: URL(string: "https://google.com")!, expectedStatusCode: 200))
checks.append(HTTPCheck(url: URL(string: "http://192.168.21.217/")!, expectedStatusCode: 404))
checks.append(HotspotCheck())

for check in checks {
    check.callback = {
        print(check.debugInformation)
    }
    check.performCheck()
}

while !checks.allSatisfy({ check in
    check.isFinished }){
    _ = RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.5))
}

print("checks all done")
