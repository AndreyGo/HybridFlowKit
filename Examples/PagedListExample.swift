import UIKit
import HybridFlowKit

final class DemoPagedListViewModel: PagedListViewModel {
    typealias Item = String

    private(set) var state = PagedListState<Item>()
    private let loaderQueue = DispatchQueue(label: "demo.pagedlist.queue")
    private var currentPage = 0

    func loadInitial() {
        state.isLoadingInitial = true
        state.items = []
        currentPage = 0
        loadPage(reset: true)
    }

    func loadMore() {
        guard !state.isLoadingMore, state.canLoadMore else { return }
        state.isLoadingMore = true
        loadPage(reset: false)
    }

    private func loadPage(reset: Bool) {
        loaderQueue.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            self.currentPage += 1
            let newItems = (0..<10).map { "Item \(self.currentPage)-\($0)" }
            self.state.items.append(contentsOf: newItems)
            self.state.isLoadingInitial = false
            self.state.isLoadingMore = false
            self.state.canLoadMore = self.currentPage < 3
        }
    }
}

final class PagedListViewController: UITableViewController {
    private let viewModel: DemoPagedListViewModel
    private let loadingPresenter: LoadingPresentable
    private let errorPresenter: ErrorPresentable

    init(viewModel: DemoPagedListViewModel,
         loadingPresenter: LoadingPresentable = DefaultLoadingPresenter(),
         errorPresenter: ErrorPresentable = DefaultErrorPresenter()) {
        self.viewModel = viewModel
        self.loadingPresenter = loadingPresenter
        self.errorPresenter = errorPresenter
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Paged List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        viewModel.loadInitial()
        loadingPresenter.showLoading(on: self)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            self.loadingPresenter.hideLoading(from: self)
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.state.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.state.items[indexPath.row]
        return cell
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.size.height * 2 {
            viewModel.loadMore()
        }
    }
}

func buildPagedListExample() -> UIViewController {
    let viewModel = DemoPagedListViewModel()
    return UINavigationController(rootViewController: PagedListViewController(viewModel: viewModel))
}
