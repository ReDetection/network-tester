import Foundation

var finished = false
var checks: [CheckProtocol] = []

checks.append(HTTPCheck(url: URL(string: "https://google.com")!))
checks.append(HTTPCheck(url: URL(string: "http://192.168.21.217/")!))
checks.append(HTTPCheck(url: URL(string: "http://home.local")!))

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
            print("status code is \(httpCheck.statusCode ?? 0)")
        }
        print("result is \(check.status)\n")
        finished = true
    }
}