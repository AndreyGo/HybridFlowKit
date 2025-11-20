import UIKit

/// Delegate notified about collapsing header progress updates.
public protocol CollapsingHeaderDelegate: AnyObject {
    /// Called whenever the collapse progress changes.
    func didUpdateProgress(_ progress: CGFloat)

    /// Called when the scroll view reaches its end, useful for lazy loading.
    func didReachEnd()
}

/// Container that combines a static header view with a scrollable content view and reports collapse progress.
open class CollapsingHeaderViewController: UIViewController {
    /// The view displayed at the top that collapses while scrolling.
    public let headerView: UIView

    /// Scrollable content hosted below the header.
    public let scrollView: UIScrollView

    /// The delegate receiving progress callbacks.
    public weak var delegate: CollapsingHeaderDelegate?

    /// The progress of the header collapse from `0` (fully visible) to `1` (fully collapsed).
    public private(set) var headerCollapseProgress: CGFloat = 0

    private let headerHeight: CGFloat
    private var headerHeightConstraint: NSLayoutConstraint?

    /// Initializes the container with provided header and scrollable content views.
    /// - Parameters:
    ///   - headerView: The view to place above the scroll view.
    ///   - scrollView: The scrollable content view. `UICollectionView` is also supported as it subclasses `UIScrollView`.
    ///   - headerHeight: The initial height for the header view.
    public init(headerView: UIView, scrollView: UIScrollView, headerHeight: CGFloat = 200) {
        self.headerView = headerView
        self.scrollView = scrollView
        self.headerHeight = max(headerHeight, 0)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        nil
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderProgress()
    }

    private func configureLayout() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.delegate = self

        view.addSubview(scrollView)
        view.addSubview(headerView)

        headerHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: headerHeight)

        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerHeightConstraint!,

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        scrollView.contentInset.top += headerHeight
        scrollView.verticalScrollIndicatorInsets.top += headerHeight
    }

    private func updateHeaderProgress() {
        let offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let clampedOffset = max(0, min(offset, headerHeight))
        let progress = headerHeight == 0 ? 1 : clampedOffset / headerHeight
        headerCollapseProgress = progress
        delegate?.didUpdateProgress(progress)
        headerHeightConstraint?.constant = max(headerHeight - clampedOffset, 0)
    }

    private func notifyIfNeededEndReached(_ scrollView: UIScrollView) {
        let visibleHeight = scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
        let threshold = scrollView.contentSize.height - visibleHeight
        if threshold <= 0 { return }

        if scrollView.contentOffset.y >= threshold {
            delegate?.didReachEnd()
        }
    }
}

extension CollapsingHeaderViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderProgress()
        notifyIfNeededEndReached(scrollView)
    }
}
