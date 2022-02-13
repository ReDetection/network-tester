import Foundation
import SwiftyPing

let googleHostName = "8.8.8.8"
let routerHostName = "192.168.12.23"

// Ping once
let once = try? SwiftyPing(host: googleHostName, configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())
once?.observer = { (response) in
    print("pinging host " + googleHostName)
    let duration = response.duration
    print("ping time: \(duration)")
    print("error status: \(String(describing: response.error))")
}
once?.targetCount = 1
try? once?.startPinging()

RunLoop.current.run(mode: .default, before: .now + 5)
