import UIKit
import NetTesterLib

class ViewController: UIViewController {
    var checks: [any CheckProtocol] = []
    let runner = CheckRunner()
    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        checks = [
            HotspotCheck().named("Internet/hotspot detection"),
            HTTPCheck(url: URL(string: "https://ya.ru")!).named("Yandex availability"),
            HTTPCheck(url: URL(string: "http://192.168.21.149/")!, expectedStatusCode: 404).named("Docker server by IP"),
            HTTPCheck(url: URL(string: "http://pihole.local/admin/")!).named("DNS pihole.local"),
            HTTPCheck(url: URL(string: "http://homeassistant.local:8123")!).named("homeassistant.local"),
        ]

        for check in checks {
            check.callback = { [weak self, weak check] in
                guard let check, let self else { return }
                self.refresh(check: check)
            }
        }

        recheck()

        tableView.refreshControl = .init()
        tableView.refreshControl?.addAction(.init(handler: { [weak self] _ in
            self?.recheck()
        }), for: .valueChanged)
    }

    private func recheck() {
        runner.run(checks: checks) { [weak self] in
            RunLoop.main.perform(inModes: [.default]) {
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
        refresh()
    }

    private func refresh(check: CheckProtocol? = nil) {
        RunLoop.main.perform(inModes: [.default]) {
            if let check, let index = self.checks.firstIndex(where: { $0 === check }) {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                return
            }
            self.tableView.reloadSections(.init(integer: 0), with: .automatic)
        }
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCheck", for: indexPath) as! CheckCell
        cell.check = checks[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {

}
extension CheckProtocol {
    func named(_ name: String) -> Self {
        self.name = name
        return self
    }
}
