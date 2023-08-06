import UIKit
import NetTesterLib

class ViewController: UIViewController {
    var checks: [any CheckProtocol] = []
    let runner = CheckRunner()
    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        checks = [
            HotspotCheck(),
            HTTPCheck(url: URL(string: "https://ya.ru")!),
        ]

        for check in checks {
            check.callback = { [weak self] in self?.refresh() }
        }

        recheck()
    }

    private func recheck() {
        runner.run(checks: checks)
    }

    private func refresh() {
        RunLoop.main.perform(inModes: [.default]) {
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
