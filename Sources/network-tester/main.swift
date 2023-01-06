import Foundation

let check = HTTPCheck(url: URL(string: "http://home.local")!)
check.performCheck()

RunLoop.current.run(mode: .default, before: .now + 5)

print(check.status)
