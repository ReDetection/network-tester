import UIKit
import NetTesterLib

open class ChecklistViewController: UIViewController {
    public var checks: [any CheckProtocol] = [
        HotspotCheck().named("Default Internet/hotspot detection"),
    ]
    let runner = CheckRunner()
    @IBOutlet private var tableView: UITableView!

    open override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(NetworkCheckCell.self, forCellReuseIdentifier: NetworkCheckCell.defaultReuseIdentifier)

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
        runner.run(checks: checks)
        tableView.refreshControl?.endRefreshing()
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

extension ChecklistViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        checks.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NetworkCheckCell.defaultReuseIdentifier, for: indexPath) as! NetworkCheckCell
        cell.check = checks[indexPath.row]
        return cell
    }
}
