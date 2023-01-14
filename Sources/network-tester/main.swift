import Foundation

var finished = false
let check = HTTPCheck(url: URL(string: "https://google.com")!)
check.callback = {
    print(check.status)
    finished = true
}
check.performCheck()

while !finished{
    _ = RunLoop.main.run(mode: .default, before: Date(timeIntervalSinceNow: 0.5))
}

