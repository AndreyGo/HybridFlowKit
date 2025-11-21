import SwiftUI
import HybridFlowKit

struct CollapsibleHeaderDemoView: View {
    private let items = Array(0..<50)
    private let viewModel = CollapsibleHeaderViewModel()

    var body: some View {
        CollapsibleHeaderView(items, id: \.self, expandedHeight: 220, collapsedHeight: 80, viewModel: viewModel) {
            LinearGradient(colors: [.pink, .purple], startPoint: .top, endPoint: .bottom)
                .overlay(
                    VStack {
                        Text("SwiftUI Collapsible Header")
                            .font(.title2)
                            .foregroundStyle(.white)
                        Text("Scroll down to collapse, up to expand")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                )
        } rowContent: { item in
            Text("Row #\(item)")
                .padding(.vertical, 8)
        }
    }
}

/// Demonstrates embedding the SwiftUI collapsible header inside UIKit flows.
public enum SwiftUICollapsibleHeaderExample {
    /// Produces a ready-to-use module backed by `BaseHostingViewController`.
    public static func makeModule() -> ScreenModule {
        let hosting = BaseHostingViewController(rootView: CollapsibleHeaderDemoView())
        return ScreenModule(viewController: hosting)
    }
}
