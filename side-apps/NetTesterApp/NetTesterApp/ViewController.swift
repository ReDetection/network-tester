import NetTesterUIKit
import NetTesterLib
import UIKit

class ViewController: ChecklistViewController {

    override func viewDidLoad() {
        checks = [
            HotspotCheck().named("Default Internet/hotspot detection"),
            HTTPCheck(url: URL(string: "https://ya.ru")!).named("Yandex availability"),
            HTTPCheck(url: URL(string: "http://192.168.21.149/")!, expectedStatusCode: 404).named("Docker server by IP"),
            HTTPCheck(url: URL(string: "http://pihole.local/admin/")!).named("DNS pihole.local"),
            HTTPCheck(url: URL(string: "http://homeassistant.local:8123")!).named("homeassistant.local"),
        ]
        super.viewDidLoad()
    }

}
