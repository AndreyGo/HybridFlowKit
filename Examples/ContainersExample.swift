import SwiftUI
import UIKit
import HybridFlowKit

// Demonstrates hosting SwiftUI inside UIKit using `BaseHostingViewController` and
// combining it with a collapsing header container.
final class DashboardHostingController: BaseHostingViewController<DashboardView> {
    init() {
        super.init(rootView: DashboardView())
        title = "Dashboard"
    }
}

struct DashboardView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("HybridFlowKit")
                .font(.largeTitle)
            Text("SwiftUI inside UIKit with Collapsing Header")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

final class CollapsingHeaderExampleController: CollapsingHeaderViewController {
    private let dataSource = TableDataSource()

    init() {
        let header = CollapsingHeaderExampleController.makeHeader()
        let tableView = CollapsingHeaderExampleController.makeTableView(dataSource: dataSource)
        super.init(headerView: header, scrollView: tableView, headerHeight: 240)
        title = "Collapsing Header"
        delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private static func makeHeader() -> UIView {
        let header = UIView()
        header.backgroundColor = .systemBlue

        let label = UILabel()
        label.text = "Pull to collapse"
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .title2)

        header.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])

        return header
    }

    private static func makeTableView(dataSource: UITableViewDataSource) -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = dataSource
        return tableView
    }
}

private final class TableDataSource: NSObject, UITableViewDataSource {
    private let items = Array(1...40).map { "Row \($0)" }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
}

extension CollapsingHeaderExampleController: CollapsingHeaderDelegate {
    func didUpdateProgress(_ progress: CGFloat) {
        Logger.log("Header collapsed to: \(progress)")
    }

    func didReachEnd() {
        Logger.log("Reached the end of the list")
    }
}
