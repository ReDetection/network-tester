import NetTesterUIKit
import NetTesterLib
import ApplePlatformChecks
import UIKit

class ViewController: ChecklistViewController {

    override func viewDidLoad() {
        checks = [
            HotspotCheck().named("Default Internet/hotspot detection"),
            HTTPCheck(url: URL(string: "https://ya.ru")!).named("Yandex availability"),
            HTTPCheck(url: URL(string: "http://192.168.21.105/")!, expectedStatusCodes: [404]).named("Docker server by IP"),
            HTTPCheck(url: URL(string: "http://pihole.local/admin/")!).named("DNS pihole.local"),
            HTTPCheck(url: URL(string: "http://homeassistant.local:8123")!).named("homeassistant.local"),
            DNSResolverCheck(hostname: "google.com").named("DNS google"),
            CertificateCheck(url: URL(string: "https://192.168.21.230:8006")!,
                             expectedCertificateData: try! Data(contentsOf: Bundle.main.url(forResource: "proxmox.local", withExtension: "cer")!)).named("proxmox"),
        ]
        super.viewDidLoad()
    }

}
