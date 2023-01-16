import Foundation

var finished = false
var checks: [CheckProtocol] = []

let googleCheck = HTTPCheck(url: URL(string: "https://google.com")!)
let checkHomeAssistant = HTTPCheck(url: URL(string: "http://192.168.21.217/")!)
checks.append(googleCheck)
checks.append(checkHomeAssistant)

for check in checks {
    addCallback(check: check)
    finished = false
    check.performCheck()

    while !finished{
    _ = RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.5))
    }
}

print("checks all done")

func addCallback(check: CheckProtocol){
    check.callback = {
        if let httpCheck = check as? HTTPCheck{
            print("checking URL " + httpCheck.request.url!.absoluteString)
        }
        print(check.status)
        finished = true
    }
}