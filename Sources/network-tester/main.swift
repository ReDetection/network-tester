import Foundation
import SwiftyPing

let googleHostName = "8.8.8.8"
let routerViaWiredHostName = "192.168.12.23"
let routerViaWifiHostName = "192.168.12.24"

var finished = false
var currentHost = routerViaWifiHostName

let ping = try? SwiftyPing(host: currentHost, configuration: PingConfiguration(interval: 0.5, with: 5), queue: DispatchQueue.global())

ping?.observer = { (response) in
    print("pinging host " + currentHost)
    let duration = response.duration
    print("ping time: \(duration)")
    print("error status: \(String(describing: response.error))")
}

ping?.targetCount = 4
try? ping?.startPinging()

ping?.finished = { (result) in
    if let loss = result.packetLoss {
        print("done! packets lost: \(loss * 100)%")
    } else {
        print("done! not sure about the packet loss")
    }
    
    finished = true
}

while !finished {
    RunLoop.current.run(mode: .default, before: .now + 5)
}
