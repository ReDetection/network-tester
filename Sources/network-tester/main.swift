import Foundation

var checks: [CheckProtocol] = []

checks.append(HTTPCheck(url: URL(string: "https://google.com")!, expectedStatusCode: 200))
checks.append(HTTPCheck(url: URL(string: "http://192.168.21.217/")!, expectedStatusCode: 404))
// checks.append(HTTPCheck(url: URL(string: "http://home.local")!))

for check in checks {
    addCallback(check: check)
    check.performCheck()
}

while !checks.allSatisfy({ check in
    check.isFinished }){
    _ = RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.5))
}

print("checks all done")

func addCallback(check: CheckProtocol){
    check.callback = {
        if let httpCheck = check as? HTTPCheck{
            print("checking URL " + httpCheck.request.url!.absoluteString)
            if let responseCodeString = httpCheck.statusCode?.asString {
                print("status code is " + responseCodeString)
            } else {
                print("no response")
            }
        }
        print("result is \(check.status)\n")
    }
}

extension Int {
    var asString: String {
        return String(self)
    }
}
