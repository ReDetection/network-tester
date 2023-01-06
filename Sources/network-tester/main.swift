import Foundation

let check = HTTPCheck(url: URL(string: "https://google.com")!)
check.performCheck()

_ = RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 5.0))

print(check.status)
