import UIKit
import NetTesterLib

@MainActor
open class ChecklistViewController: UIViewController {
    nonisolated(unsafe) public var checks: [any CheckProtocol] = [
        HotspotCheck().named("Default Internet/hotspot detection"),
    ]
    let runner = CheckRunner()
    private let tableView: UITableView = UITableView()

    open override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(NetworkCheckCell.self, forCellReuseIdentifier: NetworkCheckCell.defaultReuseIdentifier)

        runner.didUpdate = { [weak self] check in
            self?.refresh(check: check)
        }

        recheck()

        tableView.refreshControl = .init()
        tableView.refreshControl?.addAction(.init(handler: { [weak self] _ in
            self?.recheck()
        }), for: .valueChanged)
    }

    open override func loadView() {
        view = tableView
        tableView.dataSource = self
        tableView.allowsSelection = false
    }

    private func recheck() {
        Task.detached { [weak self] in
            await self?.asyncRecheck()
        }
    }

    private func asyncRecheck() async {
        await runner.run(checks: checks)
        tableView.refreshControl?.endRefreshing()
        refresh()
    }

    nonisolated private func refresh(check: CheckProtocol? = nil) {
        RunLoop.main.perform(inModes: [.default]) { [weak self] in
            guard let self else { return }
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
